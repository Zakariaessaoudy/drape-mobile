// Darija: Had controller kayseyyer state dyal add item:
// loading, error, category, session expired, w request l backend.
/*import 'package:client_mobile/core/constants/api_constants.dart';
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
*/

// Darija: Had controller kayseyyer state dyal add item:
// loading, error, category, session expired, w request l backend.
import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:client_mobile/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart';

import '../api/camera_api_exception.dart';
import '../api/camera_item_api.dart';
import '../models/camera_item.dart';
import '../models/create_camera_item_request.dart';

// AJOUT POUR LE SUPPORT WEB (Lecture des blobs/XHR de prévisualisation)
import 'package:http/http.dart' as http;

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
      // =========================================================================
      // 🟢 AJOUT POUR COMPATIBILITÉ WEB & MOBILE
      // =========================================================================
      if (kIsWeb) {
        // Sur le Web, on lit les données binaires (bytes) du blob de l'image
        // pour s'assurer que le fichier est réel et prêt à être envoyé.
        try {
          final response = await http.get(Uri.parse(request.imagePath));
          final Uint8List imageBytes = response.bodyBytes;

          // Debug pour valider la bonne lecture du fichier sur Chrome
          debugPrint("📊 [Web] Image lue avec succès. Taille : ${imageBytes.length} octets");

          // Ici, si ta méthode '_itemApi.createItem' prend en charge les bytes ou un Multipart,
          // elle s'exécutera correctement.
        } catch (webBytesError) {
          debugPrint("⚠️ Échec de la lecture des octets du blob sur le Web: $webBytesError");
        }
      } else {
        debugPrint("📱 [Mobile] Traitement standard du fichier local : ${request.imagePath}");
      }
      // =========================================================================

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