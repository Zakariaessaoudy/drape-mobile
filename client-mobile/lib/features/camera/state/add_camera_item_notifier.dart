// Darija: Had notifier kayseyyer upload dyal item mn camera.
// Screen kaybqa fih gha form UI, w hna kayn backend call w update dyal wardrobe state.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/state/auth_controller.dart';
import '../../wardrobe/models/wardrobe_item.dart';
import '../../wardrobe/state/wardrobe_controller.dart';
import '../api/camera_api_exception.dart';
import '../models/camera_item.dart';
import '../models/create_camera_item_request.dart';

class AddCameraItemState {
  const AddCameraItemState({
    this.category = ApiConstants.categoryTop,
    this.loading = false,
    this.error,
    this.sessionExpired = false,
    this.createdItem,
  });

  final String category;
  final bool loading;
  final String? error;
  final bool sessionExpired;
  final CameraItem? createdItem;

  AddCameraItemState copyWith({
    String? category,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? sessionExpired,
    CameraItem? createdItem,
  }) {
    return AddCameraItemState(
      category: category ?? this.category,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      sessionExpired: sessionExpired ?? this.sessionExpired,
      createdItem: createdItem ?? this.createdItem,
    );
  }
}

final addCameraItemNotifierProvider =
    NotifierProvider.autoDispose<AddCameraItemNotifier, AddCameraItemState>(
      AddCameraItemNotifier.new,
    );

class AddCameraItemNotifier extends Notifier<AddCameraItemState> {
  @override
  AddCameraItemState build() => const AddCameraItemState();

  void setCategory(String value) {
    state = state.copyWith(category: value);
  }

  Future<bool> createItem(CreateCameraItemRequest request) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      sessionExpired: false,
    );

    try {
      final createdItem = await ref
          .read(cameraItemApiProvider)
          .createItem(request);
      ref
          .read(wardrobeControllerProvider.notifier)
          .addOrUpdate(createdItem.toWardrobeItem());
      state = state.copyWith(loading: false, createdItem: createdItem);
      return true;
    } on CameraApiException catch (exception) {
      if (exception.sessionExpired) {
        await ref.read(authControllerProvider.notifier).logout();
      }
      state = state.copyWith(
        loading: false,
        error: exception.message,
        sessionExpired: exception.sessionExpired,
      );
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Could not add this item');
      return false;
    }
  }
}

extension on CameraItem {
  WardrobeItem toWardrobeItem() {
    return WardrobeItem(
      id: id,
      name: name,
      category: category,
      color: color,
      imageUrl: imageUrl,
      imageStatus: imageStatus,
    );
  }
}
