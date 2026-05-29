enum SlotType {
  tops,
  bottoms,
  shoes;

  String get label {
    switch (this) {
      case SlotType.tops:
        return 'TOPS';
      case SlotType.bottoms:
        return 'BOTTOMS';
      case SlotType.shoes:
        return 'SHOES';
    }
  }

  String get apiEndpoint {
    switch (this) {
      case SlotType.tops:
        return '/api/items/tops';
      case SlotType.bottoms:
        return '/api/items/bottoms';
      case SlotType.shoes:
        return '/api/items/shoes';
    }
  }
}