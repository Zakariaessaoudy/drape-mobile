// Darija: Had model kay7seb summary dyal items:
// ch7al total, ready, processing, w failed bach test screen tban wad7a.
import 'camera_item.dart';

class CameraItemCounts {
  const CameraItemCounts({
    required this.total,
    required this.ready,
    required this.processing,
    required this.failed,
  });

  final int total;
  final int ready;
  final int processing;
  final int failed;

  factory CameraItemCounts.fromItems(List<CameraItem> items) {
    return CameraItemCounts(
      total: items.length,
      ready: items.where((item) => item.isReady).length,
      processing: items.where((item) => item.isProcessing).length,
      failed: items.where((item) => item.isFailed).length,
    );
  }
}
