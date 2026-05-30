import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await _loadCameras();
  runApp(DrapeApp(cameras: cameras));
}

Future<List<CameraDescription>> _loadCameras() async {
  try {
    return availableCameras();
  } catch (_) {
    return [];
  }
}