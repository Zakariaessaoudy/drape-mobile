import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/wardrobe_item.dart';

class ItemApi {
  ItemApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<WardrobeItem>> fetchItems({String category = 'ALL'}) async {
    try {
      final json =
          await _apiClient.get(_pathForCategory(category)) as List<dynamic>;

      return json
          .map((item) => WardrobeItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const ItemApiException(
          'Session expired. Please log in again.',
          sessionExpired: true,
        );
      }

      throw ItemApiException('Could not fetch items: ${error.message}');
    } on http.ClientException {
      throw ItemApiException(
        'Cannot reach Wardrobe API at ${_apiClient.baseUrl}',
      );
    } catch (_) {
      throw const ItemApiException('Could not fetch items');
    }
  }

  String _pathForCategory(String category) {
    switch (category) {
      case ApiConstants.categoryTop:
        return ApiConstants.itemTops;
      case ApiConstants.categoryBottom:
        return ApiConstants.itemBottoms;
      case ApiConstants.categoryShoe:
        return ApiConstants.itemShoes;
      default:
        return ApiConstants.items;
    }
  }

  Future<WardrobeItem> createItem({
    required String name,
    required String category,
    required String color,
    required String imagePath,
  }) async {
    try {
      final json =
          await _apiClient.multipartPost(
                ApiConstants.items,
                fields: {
                  'name': name.trim(),
                  'category': category,
                  'color': color.trim(),
                },
                files: {'image': imagePath},
              )
              as Map<String, dynamic>;

      return WardrobeItem.fromJson(json);
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const ItemApiException(
          'Session expired. Please log in again.',
          sessionExpired: true,
        );
      }

      throw ItemApiException('Add item failed: ${error.message}');
    } on http.ClientException {
      throw ItemApiException(
        'Cannot reach Wardrobe API at ${_apiClient.baseUrl}',
      );
    } on FileSystemException {
      throw const ItemApiException('Could not read the selected image.');
    } catch (_) {
      throw const ItemApiException('Could not add this item');
    }
  }
}

class ItemApiException implements Exception {
  const ItemApiException(this.message, {this.sessionExpired = false});

  final String message;
  final bool sessionExpired;

  @override
  String toString() => message;
}
