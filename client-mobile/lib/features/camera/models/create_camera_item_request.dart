// Darija: Had model kayjme3 data li khasna bach ncreeiw chi item:
// name, category, color, w path dyal image.
class CreateCameraItemRequest {
  const CreateCameraItemRequest({
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
  });

  final String name;
  final String category;
  final String color;
  final String imagePath;

  Map<String, String> toFields() {
    return {'name': name.trim(), 'category': category, 'color': color.trim()};
  }
}
