import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../wardrobe/models/wardrobe_item.dart';
import '../../wardrobe/state/wardrobe_controller.dart';

enum OutfitSlot {
  top(ApiConstants.categoryTop, 'TOPS'),
  bottom(ApiConstants.categoryBottom, 'BOTTOMS'),
  shoe(ApiConstants.categoryShoe, 'SHOES');

  const OutfitSlot(this.category, this.label);

  final String category;
  final String label;
}

class OutfitBuilderState {
  const OutfitBuilderState({
    this.selectedTopId,
    this.selectedBottomId,
    this.selectedShoeId,
    this.isSaving = false,
    this.error,
  });

  final String? selectedTopId;
  final String? selectedBottomId;
  final String? selectedShoeId;
  final bool isSaving;
  final String? error;

  bool get canSave =>
      selectedTopId != null &&
      selectedBottomId != null &&
      selectedShoeId != null;

  OutfitBuilderState copyWith({
    String? selectedTopId,
    String? selectedBottomId,
    String? selectedShoeId,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool clearTop = false,
    bool clearBottom = false,
    bool clearShoe = false,
  }) {
    return OutfitBuilderState(
      selectedTopId: clearTop ? null : selectedTopId ?? this.selectedTopId,
      selectedBottomId: clearBottom
          ? null
          : selectedBottomId ?? this.selectedBottomId,
      selectedShoeId: clearShoe ? null : selectedShoeId ?? this.selectedShoeId,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
    );
  }

  String? selectedIdFor(OutfitSlot slot) {
    return switch (slot) {
      OutfitSlot.top => selectedTopId,
      OutfitSlot.bottom => selectedBottomId,
      OutfitSlot.shoe => selectedShoeId,
    };
  }
}

final outfitBuilderControllerProvider =
    NotifierProvider.autoDispose<OutfitBuilderController, OutfitBuilderState>(
      OutfitBuilderController.new,
    );

final outfitSlotItemsProvider = Provider.autoDispose
    .family<List<WardrobeItem>, OutfitSlot>((ref, slot) {
      final wardrobe = ref.watch(wardrobeControllerProvider);
      return wardrobe.readyItems
          .where((item) => item.category == slot.category)
          .toList();
    });

class OutfitBuilderController extends Notifier<OutfitBuilderState> {
  @override
  OutfitBuilderState build() => const OutfitBuilderState();

  bool isSelected(OutfitSlot slot, String itemId) {
    return state.selectedIdFor(slot) == itemId;
  }

  void selectItem(OutfitSlot slot, String itemId) {
    final shouldClear = state.selectedIdFor(slot) == itemId;
    state = switch (slot) {
      OutfitSlot.top => state.copyWith(
        selectedTopId: shouldClear ? null : itemId,
        clearTop: shouldClear,
        clearError: true,
      ),
      OutfitSlot.bottom => state.copyWith(
        selectedBottomId: shouldClear ? null : itemId,
        clearBottom: shouldClear,
        clearError: true,
      ),
      OutfitSlot.shoe => state.copyWith(
        selectedShoeId: shouldClear ? null : itemId,
        clearShoe: shouldClear,
        clearError: true,
      ),
    };
  }

  void setSaving(bool value) {
    state = state.copyWith(isSaving: value, clearError: true);
  }

  void setError(String message) {
    state = state.copyWith(isSaving: false, error: message);
  }
}
