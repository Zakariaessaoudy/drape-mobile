import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
    String? baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStorage = tokenStorage ?? TokenStorage(),
       baseUrl = baseUrl ?? ApiConstants.wardrobeBaseUrl;

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final String baseUrl;

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _send(
      () async => _httpClient.get(
        _uri(path, queryParameters),
        headers: await _headers(authenticated: authenticated),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _send(
      () async => _httpClient.post(
        _uri(path),
        headers: await _headers(authenticated: authenticated),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _send(
      () async => _httpClient.patch(
        _uri(path),
        headers: await _headers(authenticated: authenticated),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
    return _decode(response);
  }

  Future<void> delete(String path, {bool authenticated = true}) async {
    final response = await _send(
      () async => _httpClient.delete(
        _uri(path),
        headers: await _headers(authenticated: authenticated),
      ),
    );
    _ensureSuccess(response);
  }

  Future<dynamic> multipartPost(
    String path, {
    required Map<String, String> fields,
    required Map<String, String> files,
    bool authenticated = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.fields.addAll(fields);
    request.headers.addAll(
      await _headers(authenticated: authenticated, jsonContentType: false),
    );

    for (final entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }

    final streamedResponse = await _send(() => _httpClient.send(request));
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  Future<T> _send<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on http.ClientException catch (error) {
      throw ApiException(statusCode: 0, message: _networkErrorMessage(error));
    } catch (error) {
      if (_looksLikeNetworkError(error)) {
        throw ApiException(statusCode: 0, message: _networkErrorMessage(error));
      }
      rethrow;
    }
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse(
      '$normalizedBaseUrl$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers({
    required bool authenticated,
    bool jsonContentType = true,
  }) async {
    final headers = <String, String>{
      if (jsonContentType) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _decode(http.Response response) {
    _ensureSuccess(response);

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _errorMessage(response);
      throw ApiException(statusCode: response.statusCode, message: message);
    }
  }

  String _errorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'Request failed';
    }

    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) {
        for (final key in ['detail', 'message', 'error', 'title']) {
          final value = json[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    } catch (_) {
      // Fall back to the raw response body when the server does not return JSON.
    }

    return response.body;
  }

  bool _looksLikeNetworkError(Object error) {
    final errorText = error.toString().toLowerCase();
    return errorText.contains('socketexception') ||
        errorText.contains('connection refused') ||
        errorText.contains('failed host lookup') ||
        errorText.contains('xmlhttprequest error');
  }

  String _networkErrorMessage(Object error) {
    return 'Unable to reach the server. Please check your connection and try again.';
  }

  void close() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
