// Had file howa li kayhder m3a Wardrobe backend:
// kaycreer item b image, w kayjib list dyal items bach screens mayb9awch fihom network code.
import 'dart:convert';
import 'dart:io';

import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:client_mobile/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/camera_item.dart';
import '../models/create_camera_item_request.dart';
import '../utils/image_file_utils.dart';
import 'camera_api_exception.dart';

class CameraItemApi {
  CameraItemApi({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
    String? baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStorage = tokenStorage ?? TokenStorage(),
       baseUrl = baseUrl ?? ApiConstants.wardrobeBaseUrl;

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final String baseUrl;

  Future<CameraItem> createItem(CreateCameraItemRequest request) async {
    try {
      final multipart = http.MultipartRequest('POST', _uri(ApiConstants.items));
      multipart.headers.addAll(await _authHeaders(jsonContentType: false));
      multipart.fields.addAll(request.toFields());
      multipart.files.add(
        await http.MultipartFile.fromPath(
          'image',
          request.imagePath,
          contentType: MediaType.parse(
            ImageFileUtils.contentTypeForPath(request.imagePath),
          ),
        ),
      );

      final streamedResponse = await _httpClient.send(multipart);
      final response = await http.Response.fromStream(streamedResponse);
      _ensureSuccess(response, fallbackMessage: 'Could not add this item');

      return CameraItem.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } on CameraApiException {
      rethrow;
    } on FileSystemException {
      throw const CameraApiException('Could not read the selected image.');
    } on http.ClientException {
      throw const CameraApiException('Could not connect. Please try again.');
    } catch (_) {
      throw const CameraApiException('Could not add this item');
    }
  }

  Future<List<CameraItem>> fetchItems() async {
    try {
      final response = await _httpClient.get(
        _uri(ApiConstants.items),
        headers: await _authHeaders(),
      );
      _ensureSuccess(response, fallbackMessage: 'Could not fetch items');

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => CameraItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on CameraApiException {
      rethrow;
    } on http.ClientException {
      throw const CameraApiException('Could not connect. Please try again.');
    } catch (_) {
      throw const CameraApiException('Could not fetch items');
    }
  }

  Uri _uri(String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBaseUrl$normalizedPath');
  }

  Future<Map<String, String>> _authHeaders({
    bool jsonContentType = true,
  }) async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      throw const CameraApiException(
        'Please log in again.',
        sessionExpired: true,
      );
    }

    return {
      if (jsonContentType) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _ensureSuccess(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const CameraApiException(
        'Session expired. Please log in again.',
        sessionExpired: true,
      );
    }

    throw CameraApiException(
      response.body.isEmpty
          ? fallbackMessage
          : '$fallbackMessage: ${response.body}',
    );
  }
}
