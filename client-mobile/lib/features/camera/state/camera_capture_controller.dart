// Darija: Had controller kayssyr lcamera state:
// initialize camera, take picture, gallery, flash, loading w errors.
import 'package:camera/camera.dart' as camera;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CameraCaptureController extends ChangeNotifier {
  CameraCaptureController({required this.cameras, ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final List<camera.CameraDescription> cameras;
  final ImagePicker _imagePicker;

  camera.CameraController? _cameraController;
  bool _initialized = false;
  bool _flashOn = false;
  bool _taking = false;
  String? _error;

  camera.CameraController? get cameraController => _cameraController;
  bool get initialized => _initialized;
  bool get flashOn => _flashOn;
  bool get taking => _taking;
  String? get error => _error;
  bool get cameraUnavailable => cameras.isEmpty || _error != null;

  Future<void> initialize() async {
    if (cameras.isEmpty) return;

    _cameraController = camera.CameraController(
      cameras.first,
      camera.ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      _initialized = true;
      notifyListeners();
    } catch (_) {
      _error = 'Camera unavailable';
      notifyListeners();
    }
  }

  Future<String?> takePicture() async {
    final controller = _cameraController;
    if (_taking || controller == null || !controller.value.isInitialized) {
      return null;
    }

    _taking = true;
    notifyListeners();

    try {
      final image = await controller.takePicture();
      return image.path;
    } catch (_) {
      _error = 'Could not take picture';
      return null;
    } finally {
      _taking = false;
      notifyListeners();
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      return image?.path;
    } catch (_) {
      _error = 'Could not open gallery';
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    _flashOn = !_flashOn;
    await controller.setFlashMode(
      _flashOn ? camera.FlashMode.torch : camera.FlashMode.off,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
