import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_api.dart';
import '../../features/outfits/data/outfit_api.dart';
import '../../features/wardrobe/data/item_api.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final itemApiProvider = Provider<ItemApi>((ref) {
  return ItemApi(apiClient: ref.watch(apiClientProvider));
});

final outfitApiProvider = Provider<OutfitApi>((ref) {
  return OutfitApi(apiClient: ref.watch(apiClientProvider));
});
