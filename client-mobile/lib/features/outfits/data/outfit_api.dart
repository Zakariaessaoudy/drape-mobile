import 'package:client_mobile/core/network/api_client.dart';
import '../models/outfit_model.dart';

class OutfitApi {
  OutfitApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Outfit>> fetchOutfits() async {
    final data = await _apiClient.get('/api/outfits') as List<dynamic>;
    return data
        .map((e) => Outfit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Outfit> createOutfit({
    required String name,
    required String description,
    required String topId,
    required String bottomId,
    required String shoeId,
  }) async {
    final data = await _apiClient.post(
      '/api/outfits',
      body: {
        'name': name,
        'description': description,
        'itemIds': [topId, bottomId, shoeId],
      },
    );
    return Outfit.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteOutfit(String outfitId) async {
    await _apiClient.delete('/api/outfits/$outfitId');
  }
}