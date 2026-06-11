import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/outfit_api.dart';
import '../models/outfit.dart';

class OutfitListState {
  const OutfitListState({
    this.outfits = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final List<Outfit> outfits;
  final bool loading;
  final bool loaded;
  final String? error;

  OutfitListState copyWith({
    List<Outfit>? outfits,
    bool? loading,
    bool? loaded,
    String? error,
    bool clearError = false,
  }) {
    return OutfitListState(
      outfits: outfits ?? this.outfits,
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final outfitListControllerProvider =
    NotifierProvider<OutfitListController, OutfitListState>(
      OutfitListController.new,
    );

class OutfitListController extends Notifier<OutfitListState> {
  @override
  OutfitListState build() => const OutfitListState();

  Future<void> loadIfNeeded() async {
    if (state.loaded || state.loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final outfits = await ref.read(outfitApiProvider).fetchOutfits();
      state = OutfitListState(outfits: outfits, loaded: true);
    } on OutfitApiException catch (error) {
      state = state.copyWith(
        loading: false,
        loaded: true,
        error: error.message,
      );
    }
  }

  Future<bool> createOutfit({
    required String name,
    required String description,
    required String topId,
    required String bottomId,
    required String shoeId,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final outfit = await ref
          .read(outfitApiProvider)
          .createOutfit(
            name: name,
            description: description,
            topId: topId,
            bottomId: bottomId,
            shoeId: shoeId,
          );
      state = state.copyWith(outfits: [outfit, ...state.outfits], loaded: true);
      return true;
    } on OutfitApiException catch (error) {
      state = state.copyWith(error: error.message);
      return false;
    }
  }

  Future<void> deleteOutfit(String outfitId) async {
    final previousOutfits = state.outfits;
    state = state.copyWith(
      outfits: previousOutfits
          .where((outfit) => outfit.id != outfitId)
          .toList(),
      clearError: true,
    );

    try {
      await ref.read(outfitApiProvider).deleteOutfit(outfitId);
    } on OutfitApiException catch (error) {
      state = state.copyWith(outfits: previousOutfits, error: error.message);
    }
  }
}
