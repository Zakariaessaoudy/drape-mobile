// Darija: Had screen howa camera principal:
// kay7el camera/gallery, kaykhlli user ykhd picture, w kaydiha l confirmation screen.
import 'package:camera/camera.dart';
import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/camera/screens/image_confirm_screen.dart';
import 'package:client_mobile/features/camera/state/camera_capture_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SmartCameraScreen extends StatelessWidget {
  const SmartCameraScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraCaptureController(cameras: cameras)..initialize(),
      child: const _SmartCameraView(),
    );
  }
}

class _SmartCameraView extends StatelessWidget {
  const _SmartCameraView();

  Future<void> _openConfirm(
    BuildContext context,
    Future<String?> Function() selectImage,
  ) async {
    final imagePath = await selectImage();
    if (imagePath == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageConfirmScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraCaptureController>();

    if (controller.cameraUnavailable) {
      return _CameraUnavailable(
        onOpenGallery: () => _openConfirm(
          context,
          context.read<CameraCaptureController>().pickFromGallery,
        ),
      );
    }

    if (!controller.initialized || controller.cameraController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AuthColors.neon)),
      );
    }

    final cameraController = controller.cameraController!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: cameraController.value.previewSize!.height,
                height: cameraController.value.previewSize!.width,
                child: CameraPreview(cameraController),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                _CameraControls(
                  taking: controller.taking,
                  flashOn: controller.flashOn,
                  onOpenGallery: () => _openConfirm(
                    context,
                    context.read<CameraCaptureController>().pickFromGallery,
                  ),
                  onTakePicture: () => _openConfirm(
                    context,
                    context.read<CameraCaptureController>().takePicture,
                  ),
                  onToggleFlash: context
                      .read<CameraCaptureController>()
                      .toggleFlash,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.onOpenGallery});

  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.no_photography_outlined,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Camera unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose an image from your gallery instead.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: onOpenGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuthColors.neon,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Open gallery'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraControls extends StatelessWidget {
  const _CameraControls({
    required this.taking,
    required this.flashOn,
    required this.onOpenGallery,
    required this.onTakePicture,
    required this.onToggleFlash,
  });

  final bool taking;
  final bool flashOn;
  final VoidCallback onOpenGallery;
  final VoidCallback onTakePicture;
  final VoidCallback onToggleFlash;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onOpenGallery,
            icon: const Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: 32,
            ),
            tooltip: 'Gallery',
          ),
          GestureDetector(
            onTap: onTakePicture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: taking
                    ? AuthColors.neon.withValues(alpha: 0.6)
                    : AuthColors.neon,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggleFlash,
            icon: Icon(
              flashOn ? Icons.flash_on : Icons.flash_off,
              color: flashOn ? AuthColors.neon : Colors.white,
              size: 32,
            ),
            tooltip: 'Flash',
          ),
        ],
      ),
    );
  }
}
