import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart' as camera_pkg;

// Importations du client réseau et du stockage
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

// Importations du module Caméra et Dressing réel
import 'features/camera/state/add_camera_item_controller.dart';
import 'features/camera/state/camera_capture_controller.dart';
import 'features/camera/state/item_fetch_controller.dart';

// Importations du module Outfit Builder

import 'features/outfits/controllers/outfit_builder_controller.dart';
import 'features/outfits/screens/outfit_and_dressing_hub.dart';

void main() async {
  // S'assure que les liaisons des widgets Flutter sont initialisées avant le chargement asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // 🟢 INJECTION DU TOKEN DE TEST GÉNÉRÉ DEPUIS POSTMAN (PORT 8084)
  // =========================================================================
  final tokenStorage = TokenStorage();
  const String myPostmanToken = "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJmYXRpbWEuZXp6YWhyYUBleGFtcGxlLmNvbSIsImlhdCI6MTc3OTIxNzU1MCwiZXhwIjoxNzc5MzAzOTUwfQ.cSYmF9Qm9KCeJNKaNc5eeJtg2Cp6UB_Cja41M48q29ZuMlGrXzF4cLEMYXsJHvVX";

  await tokenStorage.saveToken(myPostmanToken);
  // =========================================================================

  List<camera_pkg.CameraDescription> availableCameras = [];

  try {
    // Récupération des caméras physiques pour ton SmartCameraScreen matériel
    availableCameras = await camera_pkg.availableCameras();
  } catch (e) {
    debugPrint("Erreur lors du chargement des caméras matérielles : $e");
  }

  // Instance partagée de ton ApiClient
  final globalApiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        // 1. Contrôleur de capture d'images (SmartCameraScreen / Galerie)
        ChangeNotifierProvider<CameraCaptureController>(
          create: (_) => CameraCaptureController(cameras: availableCameras),
        ),
        // 2. Contrôleur de récupération globale des articles du dressing
        ChangeNotifierProvider<ItemFetchController>(
          create: (_) => ItemFetchController()..load(),
        ),
        // 3. Contrôleur d'ajout/création d'un nouvel article via IA
        ChangeNotifierProvider<AddCameraItemController>(
          create: (_) => AddCameraItemController(),
        ),
        // 4. Contrôleur de ton OutfitBuilder
        ChangeNotifierProvider<OutfitBuilderProvider>(
          create: (_) => OutfitBuilderProvider(apiClient: globalApiClient),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dressing & Outfit Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const OutfitAndDressingHub(),
      routes: {
        '/home': (context) => const OutfitAndDressingHub(),
      },
    );
  }
}