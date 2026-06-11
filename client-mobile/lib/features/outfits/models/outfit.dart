class Outfit {
  const Outfit({
    required this.id,
    required this.name,
    this.description,
    this.top,
    this.bottom,
    this.shoe,
  });

  final String id;
  final String name;
  final String? description;
  final OutfitItem? top;
  final OutfitItem? bottom;
  final OutfitItem? shoe;

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      top: _itemFromJson(json['top']),
      bottom: _itemFromJson(json['bottom']),
      shoe: _itemFromJson(json['shoe']),
    );
  }

  static OutfitItem? _itemFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return OutfitItem.fromJson(json);
  }
}

class OutfitItem {
  const OutfitItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imageStatus,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String color;
  final String imageStatus;
  final String? imageUrl;

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      imageStatus: json['imageStatus'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
