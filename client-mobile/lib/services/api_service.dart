import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_model.dart';

class ApiService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8084';
    }
    if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'http://localhost:8084';
    }
    return 'http://10.0.2.2:8084';
  }

  Future<List<ItemModel>> fetchItems({String? category}) async {
    final uri = Uri.parse('$_baseUrl/api/items').replace(
      queryParameters: category == null ? null : <String, String>{'categories': category},
    );

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Failed to fetch items (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => ItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ItemModel> addItem({
    required String name,
    required String category,
    required String color,
    required XFile imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/items'),
    );

    request.headers.addAll(await _headers());
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['color'] = color;
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Failed to add item (${response.statusCode})');
    }

    return ItemModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _readToken();
    return <String, String>{
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = <String>['token', 'auth_token', 'access_token'];

    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    throw HttpException('Missing auth token in SharedPreferences.');
  }
}
