// Darija: Had controller kayseyyer test list dyal items:
// kayfetchi mn backend, kay7fed loading/error/items, w kayclear token ila session salat.
import 'package:client_mobile/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart';

import '../api/camera_api_exception.dart';
import '../api/camera_item_api.dart';
import '../models/camera_item.dart';
import '../models/camera_item_counts.dart';

class ItemFetchController extends ChangeNotifier {
  ItemFetchController({CameraItemApi? itemApi, TokenStorage? tokenStorage})
    : _itemApi = itemApi ?? CameraItemApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final CameraItemApi _itemApi;
  final TokenStorage _tokenStorage;

  bool loading = false;
  String? error;
  List<CameraItem> items = const [];

  CameraItemCounts get counts => CameraItemCounts.fromItems(items);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      items = await _itemApi.fetchItems();
    } on CameraApiException catch (exception) {
      error = exception.message;
      if (exception.sessionExpired) {
        await _tokenStorage.clearToken();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
