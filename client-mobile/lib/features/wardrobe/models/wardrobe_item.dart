class WardrobeItem {
  const WardrobeItem({
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
  final String? imageUrl;
  final String imageStatus;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      color: json['color'] as String,
      imageUrl: json['imageUrl'] as String?,
      imageStatus: json['imageStatus'] as String,
    );
  }
}
