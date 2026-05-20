// Darija: Had model kayrepresenti item jay mn backend:
// smiya, category, color, imageUrl, w status dyal image.
class CameraItem {
  const CameraItem({
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

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isReady => imageStatus == 'READY';
  bool get isProcessing => imageStatus == 'PROCESSING';
  bool get isFailed => imageStatus == 'FAILED';

  factory CameraItem.fromJson(Map<String, dynamic> json) {
    return CameraItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageStatus: json['imageStatus'] as String? ?? 'UNKNOWN',
    );
  }

}
