class Item {
  final String id;
  final String name;
  final String color;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final String imageStatus;       // ← AJOUTE

  const Item({
    required this.id,
    required this.name,
    required this.color,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.imageStatus = 'READY',   // ← AJOUTE
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    name: json['name'],
    color: json['color'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    categoryId: json['category']?['id'] ?? json['categorieId'] ?? '',
    categoryName: json['category']?['name'] ?? json['categorie']?['name'] ?? '',
    imageStatus: json['imageStatus'] ?? 'READY',  // ← AJOUTE
  );

  bool get hasImage => imageUrl.isNotEmpty;
  bool get isReady => imageStatus == 'READY';
}