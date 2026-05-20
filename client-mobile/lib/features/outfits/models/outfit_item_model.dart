class Item {
  final String id;
  final String name;
  final String color;
  final String imageUrl;
  final String categoryId;
  final String categoryName;

  // CORRECTION : Supprime le paramètre "required bool hasImage" d'ici
  const Item({
    required this.id,
    required this.name,
    required this.color,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    color: json['color'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    categoryId: json['categorieId'] ?? json['categorie']?['id'] ?? '',
    categoryName: json['categorie']?['name'] ?? '',
    // CORRECTION : Ne passe rien ici, le getter dynamique s'en charge tout seul !
  );

  // Ce getter calcule automatiquement si l'image est présente ou non
  bool get hasImage => imageUrl.isNotEmpty;
}