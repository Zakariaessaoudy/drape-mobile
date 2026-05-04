// Darija: Had controller kayseyyer state dyal add item:
// loading, error, category, session expired, w request l backend.
import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:client_mobile/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart';

import '../api/camera_api_exception.dart';
import '../api/camera_item_api.dart';
import '../models/camera_item.dart';
import '../models/create_camera_item_request.dart';

class AddCameraItemController extends ChangeNotifier {
  AddCameraItemController({CameraItemApi? itemApi, TokenStorage? tokenStorage})
    : _itemApi = itemApi ?? CameraItemApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final CameraItemApi _itemApi;
  final TokenStorage _tokenStorage;

  String category = ApiConstants.categoryTop;
  bool loading = false;
  String? error;
  bool sessionExpired = false;
  CameraItem? createdItem;

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  Future<bool> createItem(CreateCameraItemRequest request) async {
    loading = true;
    error = null;
    sessionExpired = false;
    notifyListeners();

    try {
      createdItem = await _itemApi.createItem(request);
      return true;
    } on CameraApiException catch (exception) {
      error = exception.message;
      sessionExpired = exception.sessionExpired;
      if (sessionExpired) {
        await _tokenStorage.clearToken();
      }
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
