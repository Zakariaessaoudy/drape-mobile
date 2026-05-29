import 'package:camera/camera.dart';
import 'package:client_mobile/core/storage/token_storage.dart';
import 'package:client_mobile/features/auth/screens/login_screen.dart';
import 'package:client_mobile/features/camera/smart_camera_screen.dart';
import 'package:client_mobile/features/navigation/screens/overlay_feature_screens.dart';
import 'package:client_mobile/features/outfits/screens/outfits_screen.dart';
import 'package:client_mobile/features/profile/screens/profile_screen.dart';
import 'package:client_mobile/features/wardrobe/screens/wardrobe_screen.dart';
import 'package:client_mobile/shared/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/outfits/screens/outfit_builder_screen.dart';

  Future<void> _openCamera() async {
    final cameras = await _loadCameras();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SmartCameraScreen(cameras: cameras),
      ),
    );
  }

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

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.index});

  final int index;

  static const List<String> _names = ['WARDROBE', 'TRY-ON', 'FEED', 'PROFILE'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Section $index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _names[index],
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}