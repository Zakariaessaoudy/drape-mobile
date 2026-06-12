import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../features/wardrobe/models/wardrobe_item.dart';

class LocalImageCache {
  LocalImageCache({
    http.Client? httpClient,
    Future<String> Function(String imageUrl)? displayUrlFor,
  }) : _httpClient = httpClient ?? http.Client(),
       _displayUrlFor = displayUrlFor ?? ((imageUrl) async => imageUrl);

  final http.Client _httpClient;
  final Future<String> Function(String imageUrl) _displayUrlFor;

  Future<String?> getLocalPath(String itemId, String? imageUrl) async {
    if (!_hasImage(imageUrl)) return null;

    final directory = await _cacheDirectory();
    final index = await _readIndex(directory);
    final file = File('${directory.path}/$itemId.img');

    if (await file.exists() && index[itemId] == imageUrl) {
      return file.path;
    }

    return null;
  }

  Future<String?> cacheImage(String itemId, String? imageUrl) async {
    if (!_hasImage(imageUrl)) return null;

    try {
      final existingPath = await getLocalPath(itemId, imageUrl);
      if (existingPath != null) return existingPath;

      final directory = await _cacheDirectory();
      final displayUrl = await _displayUrlFor(imageUrl!);
      final response = await _httpClient.get(Uri.parse(displayUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final file = File('${directory.path}/$itemId.img');
      await file.writeAsBytes(response.bodyBytes, flush: true);

      final index = await _readIndex(directory);
      index[itemId] = imageUrl;
      await _writeIndex(directory, index);

      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> cacheImages(List<WardrobeItem> items) async {
    final paths = <String, String>{};

    for (final item in items) {
      if (item.imageStatus.toUpperCase() != 'READY') continue;

      final path = await cacheImage(item.id, item.imageUrl);
      if (path != null) {
        paths[item.id] = path;
      }
    }

    return paths;
  }

  Future<void> clear() async {
    try {
      final directory = await _cacheDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (_) {
      // Cache cleanup should never break the app.
    }
  }

  Future<void> removeImage(String itemId) async {
    try {
      final directory = await _cacheDirectory();
      final file = File('${directory.path}/$itemId.img');
      if (await file.exists()) {
        await file.delete();
      }

      final index = await _readIndex(directory);
      index.remove(itemId);
      await _writeIndex(directory, index);
    } catch (_) {
      // Cache cleanup should never break the app.
    }
  }

  bool _hasImage(String? imageUrl) {
    return imageUrl != null && imageUrl.trim().isNotEmpty;
  }

  Future<Directory> _cacheDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/wardrobe_images');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<Map<String, String>> _readIndex(Directory directory) async {
    try {
      final file = File('${directory.path}/index.json');
      if (!await file.exists()) return {};

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return {};

      return decoded.map(
        (key, value) => MapEntry(key, value is String ? value : ''),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeIndex(
    Directory directory,
    Map<String, String> index,
  ) async {
    final file = File('${directory.path}/index.json');
    await file.writeAsString(jsonEncode(index), flush: true);
  }
}
