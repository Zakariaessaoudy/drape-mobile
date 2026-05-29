class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imageUrl,
    required this.imageStatus,
  });

  final String id;
  final String name;
  final String category;
  final String color;
  final String? imageUrl;
  final String imageStatus;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      color: (json['color'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
      imageStatus: (json['imageStatus'] ?? 'PROCESSING') as String,
    );
  }
}
