import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item_model.dart';
import '../services/api_service.dart';

class WardrobeProvider extends ChangeNotifier {
  WardrobeProvider({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  List<ItemModel> _items = <ItemModel>[];
  String _selectedFilter = 'ALL';
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  List<ItemModel> get items => _items;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchItems({String? filter}) async {
    if (filter != null && filter != _selectedFilter) {
      _selectedFilter = filter;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _apiService.fetchItems(
        category: _selectedFilter == 'ALL' ? null : _selectedFilter,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(String filter) async {
    if (_selectedFilter == filter) {
      return;
    }
    await fetchItems(filter: filter);
  }

  Future<void> addItem({
    required String name,
    required String category,
    required String color,
    required XFile imageFile,
  }) async {
    final newItem = await _apiService.addItem(
      name: name,
      category: category,
      color: color,
      imageFile: imageFile,
    );

    if (_selectedFilter == 'ALL' || _selectedFilter == category) {
      _items = <ItemModel>[newItem, ..._items];
      notifyListeners();
    }

    _startPolling(newItem.id);
  }

  void _startPolling(String itemId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final allItems = await _apiService.fetchItems();
        final item = allItems.cast<ItemModel?>().firstWhere(
              (candidate) => candidate?.id == itemId,
              orElse: () => null,
            );

        if (item == null ||
            (item.imageStatus != 'PROCESSING' &&
                item.imageStatus != 'PENDING')) {
          timer.cancel();
          _pollingTimer = null;
        }

        await fetchItems();
      } catch (_) {
        timer.cancel();
        _pollingTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
