import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/outfits/screens/outfit_builder_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final cameras = await _loadCameras();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const OutfitBuilderScreen(),
  ));
}

Future<List<CameraDescription>> _loadCameras() async {
  try {
    return availableCameras();
  } catch (_) {
    return [];
  }
}