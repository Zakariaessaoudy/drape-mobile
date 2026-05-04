// Darija: Had file kay7wel S3 private image URL l signed URL bach l image tban f app.
// Ila URL deja signed ola machi S3, kayrj3ha kif ma hiya.
import 'dart:convert';

import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

import '../utils/s3_image_utils.dart';
import 'camera_api_exception.dart';

class SignedImageApi {
  SignedImageApi({http.Client? httpClient, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      baseUrl = baseUrl ?? ApiConstants.aiBaseUrl;

  final http.Client _httpClient;
  final String baseUrl;

  Future<String> displayUrlFor(String rawImageUrl) async {
    if (S3ImageUtils.isSignedUrl(rawImageUrl)) return rawImageUrl;

    final s3Key = S3ImageUtils.extractS3Key(rawImageUrl);
    if (s3Key == null) return rawImageUrl;

    final response = await _httpClient.get(
      Uri.parse('$baseUrl/image/${S3ImageUtils.encodeS3Key(s3Key)}'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CameraApiException('Signed URL failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['url'] as String;
  }
}
