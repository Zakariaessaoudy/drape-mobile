import 'outfit_item_model.dart';

class Outfit {
  final String id;
  final String name;
  final String description;
  final List<Item> items;

  const Outfit({
    required this.id,
    required this.name,
    this.description = '',
    required this.items,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => Item.fromJson(e))
        .toList(),
  );
}