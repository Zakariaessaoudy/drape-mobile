import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/outfit.dart';

class OutfitApi {
  OutfitApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Outfit>> fetchOutfits() async {
    try {
      final json = await _apiClient.get(ApiConstants.outfits) as List<dynamic>;

      return json
          .map((outfit) => Outfit.fromJson(outfit as Map<String, dynamic>))
          .toList();
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const OutfitApiException(
          'Session expired. Please log in again.',
          sessionExpired: true,
        );
      }

      throw OutfitApiException('Could not fetch outfits: ${error.message}');
    } on http.ClientException {
      throw OutfitApiException(
        'Cannot reach Wardrobe API at ${_apiClient.baseUrl}',
      );
    } catch (_) {
      throw const OutfitApiException('Could not fetch outfits');
    }
  }

  Future<Outfit> createOutfit({
    required String name,
    required String description,
    required String topId,
    required String bottomId,
    required String shoeId,
  }) async {
    try {
      final json =
          await _apiClient.post(
                ApiConstants.outfits,
                body: {
                  'name': name.trim(),
                  'description': description.trim(),
                  'topId': topId,
                  'bottomId': bottomId,
                  'shoeId': shoeId,
                },
              )
              as Map<String, dynamic>;

      return Outfit.fromJson(json);
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const OutfitApiException(
          'Session expired. Please log in again.',
          sessionExpired: true,
        );
      }

      throw OutfitApiException('Could not save outfit: ${error.message}');
    } on http.ClientException {
      throw OutfitApiException(
        'Cannot reach Wardrobe API at ${_apiClient.baseUrl}',
      );
    } catch (_) {
      throw const OutfitApiException('Could not save outfit');
    }
  }

  Future<void> deleteOutfit(String outfitId) async {
    try {
      await _apiClient.delete('${ApiConstants.outfits}/$outfitId');
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const OutfitApiException(
          'Session expired. Please log in again.',
          sessionExpired: true,
        );
      }

      throw OutfitApiException('Could not delete outfit: ${error.message}');
    } on http.ClientException {
      throw OutfitApiException(
        'Cannot reach Wardrobe API at ${_apiClient.baseUrl}',
      );
    } catch (_) {
      throw const OutfitApiException('Could not delete outfit');
    }
  }
}

class OutfitApiException implements Exception {
  const OutfitApiException(this.message, {this.sessionExpired = false});

  final String message;
  final bool sessionExpired;

  @override
  String toString() => message;
}
