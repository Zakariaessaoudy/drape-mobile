import 'package:camera/camera.dart';
import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/camera/smart_camera_screen.dart';
import 'package:client_mobile/shared/widgets/drape_logo.dart';
import 'package:client_mobile/shared/widgets/neon_button.dart';
import 'package:flutter/material.dart';

import 'core/storage/token_storage.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/outfits/screens/outfit_builder_screen.dart';
class DrapeApp extends StatelessWidget {
  const DrapeApp({super.key, this.cameras = const []});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drape',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Arial',
      ),
      home: _AuthGate(cameras: cameras),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => _SignedInScreen(cameras: cameras),
        '/outfit-builder':  (_) => OutfitBuilderScreen(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenStorage().hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AuthColors.neon),
            ),
          );
        }

        return snapshot.data!
            ? _SignedInScreen(cameras: cameras)
            : const LoginScreen();
      },
    );
  }
}

class _SignedInScreen extends StatelessWidget {
  const _SignedInScreen({required this.cameras});

  final List<CameraDescription> cameras;

  Future<void> _logout(BuildContext context) async {
    await TokenStorage().clearToken();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DrapeLogo(
              size: 46,
              assetPath: 'assets/images/drape_nobg.png',
            ),
            const SizedBox(height: 24),
            const Text(
              'You are signed in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: NeonButton(
                text: 'ADD ITEM',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SmartCameraScreen(cameras: cameras),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 220,
              child: NeonButton(
                text: 'BUILD OUTFIT',
                onPressed: () => Navigator.of(context).pushNamed('/outfit-builder'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              child: NeonButton(
                text: 'Logout',
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
