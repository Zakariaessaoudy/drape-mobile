import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../camera/api/signed_image_api.dart';
import '../models/outfit_item_model.dart';
import '../models/slot_type.dart';
import '../data/outfit_api.dart';
class OutfitBuilderProvider extends ChangeNotifier {
  OutfitBuilderProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient() {
    _loadAll();
  }

  final ApiClient _apiClient;
  final SignedImageApi _signedImageApi = SignedImageApi();

 

  final Map<SlotType, List<Item>> _slotItems = {
    SlotType.tops: [],
    SlotType.bottoms: [],
    SlotType.shoes: [],
  };

  final Map<SlotType, String?> _selectedId = {
    SlotType.tops: null,
    SlotType.bottoms: null,
    SlotType.shoes: null,
  };

  final Map<SlotType, bool> _loading = {
    SlotType.tops: false,
    SlotType.bottoms: false,
    SlotType.shoes: false,
  };

  final Map<SlotType, String?> _error = {
    SlotType.tops: null,
    SlotType.bottoms: null,
    SlotType.shoes: null,
  };

  bool _isSaving = false;
  bool _saved = false;
  String? _saveError;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Item> itemsFor(SlotType slot) => _slotItems[slot] ?? [];

  Item? selectedItemFor(SlotType slot) {
    final id = _selectedId[slot];
    if (id == null) return null;
    try {
      return itemsFor(slot).firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isSelected(SlotType slot, String itemId) =>
      _selectedId[slot] == itemId;

  bool isLoadingSlot(SlotType slot) => _loading[slot] ?? false;

  String? errorFor(SlotType slot) => _error[slot];

  bool get isSaving => _isSaving;

  bool get saved => _saved;

  String? get saveError => _saveError;

  /// True only when all 3 slots have a selection
  bool get canSave =>
      _selectedId[SlotType.tops] != null &&
          _selectedId[SlotType.bottoms] != null &&
          _selectedId[SlotType.shoes] != null;

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    await Future.wait(
      SlotType.values.map((slot) => _loadSlot(slot)),
    );
  }

  Future<void> _loadSlot(SlotType slot) async {
    _loading[slot] = true;
    _error[slot] = null;
    notifyListeners();

    try {
      final data = await _apiClient.get(slot.apiEndpoint) as List<dynamic>;

      // Étape 1 : Conversion et filtrage
      final rawItems = data
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .where((item) => item.hasImage)
          .toList();

      // TEST : On utilise l'URL d'origine sans passer par SignedImageApi
      _slotItems[slot] = rawItems;

    } on ApiException catch (e) {
      _error[slot] = e.statusCode == 401 ? 'Session expired.' : 'Error ${e.statusCode}.';
    } catch (_) {
      _error[slot] = 'Cannot reach server.';
    }

    _loading[slot] = false;
    notifyListeners();
  }
  Future<void> retrySlot(SlotType slot) => _loadSlot(slot);

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectItem(SlotType slot, String itemId) {
    // Tap again on selected item → deselect
    _selectedId[slot] = _selectedId[slot] == itemId ? null : itemId;
    _saved = false;
    _saveError = null;
    notifyListeners();
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<bool> saveOutfit({
    required String name,
    required String description,
  }) async {
    if (!canSave) return false;

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      await OutfitApi(_apiClient).createOutfit(
        name: name,
        description: description,
        topId: _selectedId[SlotType.tops]!,
        bottomId: _selectedId[SlotType.bottoms]!,
        shoeId: _selectedId[SlotType.shoes]!,
      );
      _isSaving = false;
      _saved = true;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        _saveError = 'Session expired. Please log in again.';
      } else {
        _saveError = 'Could not save outfit (${e.statusCode}).';
      }
    } catch (_) {
      _saveError = 'Cannot reach server.';
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }
}