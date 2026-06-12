import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../data/item_api.dart';
import '../models/wardrobe_item.dart';

class WardrobeState {
  const WardrobeState({
    this.items = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
    this.localImagePaths = const {},
  });

  final List<WardrobeItem> items;
  final bool loading;
  final bool loaded;
  final String? error;
  final Map<String, String> localImagePaths;

  WardrobeState copyWith({
    List<WardrobeItem>? items,
    bool? loading,
    bool? loaded,
    String? error,
    Map<String, String>? localImagePaths,
    bool clearError = false,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      error: clearError ? null : error ?? this.error,
      localImagePaths: localImagePaths ?? this.localImagePaths,
    );
  }

  String? localImagePathFor(String itemId) => localImagePaths[itemId];

  List<WardrobeItem> byCategory(String category) {
    if (category == 'ALL') return items;
    return items.where((item) => item.category == category).toList();
  }

  List<WardrobeItem> get readyItems =>
      items.where((item) => item.imageStatus.toUpperCase() == 'READY').toList();

  List<WardrobeItem> get processingItems => items
      .where((item) => item.imageStatus.toUpperCase() == 'PROCESSING')
      .toList();

  List<WardrobeItem> get failedItems => items
      .where((item) => item.imageStatus.toUpperCase() == 'FAILED')
      .toList();
}

final wardrobeControllerProvider =
    NotifierProvider<WardrobeController, WardrobeState>(WardrobeController.new);

class WardrobeController extends Notifier<WardrobeState> {
  @override
  WardrobeState build() => const WardrobeState();

  Future<void> loadIfNeeded() async {
    if (state.loaded || state.loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final items = await ref.read(itemApiProvider).fetchItems();
      final localImagePaths = await ref
          .read(localImageCacheProvider)
          .cacheImages(items);
      state = WardrobeState(
        items: items,
        localImagePaths: localImagePaths,
        loaded: true,
      );
    } on ItemApiException catch (error) {
      state = state.copyWith(
        loading: false,
        loaded: true,
        error: error.message,
      );
    }
  }

  void addOrUpdate(WardrobeItem item) {
    final nextItems = [...state.items];
    final index = nextItems.indexWhere((current) => current.id == item.id);
    if (index == -1) {
      nextItems.insert(0, item);
    } else {
      nextItems[index] = item;
    }
    state = state.copyWith(items: nextItems, loaded: true);
    unawaited(cacheItemImage(item));
  }

  Future<bool> deleteItem(String itemId) async {
    state = state.copyWith(clearError: true);
    try {
      await ref.read(itemApiProvider).deleteItem(itemId);
      final nextItems = state.items.where((item) => item.id != itemId).toList();
      final nextLocalPaths = {...state.localImagePaths}..remove(itemId);
      state = state.copyWith(
        items: nextItems,
        localImagePaths: nextLocalPaths,
        loaded: true,
      );
      unawaited(ref.read(localImageCacheProvider).removeImage(itemId));
      return true;
    } on ItemApiException catch (error) {
      state = state.copyWith(error: error.message);
      return false;
    }
  }

  Future<void> cacheItemImage(WardrobeItem item) async {
    if (item.imageStatus.toUpperCase() != 'READY') return;

    final path = await ref
        .read(localImageCacheProvider)
        .cacheImage(item.id, item.imageUrl);
    if (path == null) return;

    final itemStillExists = state.items.any((current) => current.id == item.id);
    if (!itemStillExists) return;

    state = state.copyWith(
      localImagePaths: {...state.localImagePaths, item.id: path},
    );
  }

  List<WardrobeItem> readyItemsForCategory(String category) {
    return state.readyItems.where((item) => item.category == category).toList();
  }

  List<WardrobeItem> get readyTops =>
      readyItemsForCategory(ApiConstants.categoryTop);

  List<WardrobeItem> get readyBottoms =>
      readyItemsForCategory(ApiConstants.categoryBottom);

  List<WardrobeItem> get readyShoes =>
      readyItemsForCategory(ApiConstants.categoryShoe);
}
