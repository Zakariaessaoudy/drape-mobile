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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: _AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const _HomeScreen(),
        '/saved-outfits': (_) => const OutfitsScreen(),
        FavoritesScreen.routeName: (_) => const FavoritesScreen(),
        StylePreferencesScreen.routeName: (_) => const StylePreferencesScreen(),
        ProcessingItemsScreen.routeName: (_) => const ProcessingItemsScreen(),
        UploadHistoryScreen.routeName: (_) => const UploadHistoryScreen(),
        WardrobeInsightsScreen.routeName: (_) => const WardrobeInsightsScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        HelpScreen.routeName: (_) => const HelpScreen(),
        '/profile': (context) => ProfileScreen(
          onOpenWardrobe: () => Navigator.of(context).pop(),
          onOpenOutfits: () =>
              Navigator.of(context).pushNamed('/saved-outfits'),
          onSignOut: () async {
            await TokenStorage().clearToken();
            if (!context.mounted) return;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (_) => false);
          },
        ),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenStorage().hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFC6F135)),
            ),
          );
        }

        return snapshot.data! ? const _HomeScreen() : const LoginScreen();
      },
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategoryFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentNavIndex: _currentIndex,
      onNavTap: _selectTab,
      showCategoryFilters: _currentIndex == 0,
      selectedCategoryFilter: _selectedCategoryFilter,
      onCategoryFilterChanged: _selectCategoryFilter,
      body: _buildCurrentSection(),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _selectCategoryFilter(String filter) {
    setState(() {
      _selectedCategoryFilter = filter;
    });
  }

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

  Future<List<CameraDescription>> _loadCameras() async {
    try {
      return availableCameras();
    } catch (_) {
      return [];
    }
  }

  Future<void> _signOut() async {
    await TokenStorage().clearToken();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Widget _buildCurrentSection() {
    if (_currentIndex == 0) {
      return WardrobeScreen(
        selectedFilter: _selectedCategoryFilter,
        onAddItem: _openCamera,
      );
    }

    if (_currentIndex == 1) {
      return const OutfitsScreen();
    }

    if (_currentIndex == 3) {
      return ProfileScreen(
        onOpenWardrobe: () => _selectTab(0),
        onOpenOutfits: () => _selectTab(1),
        onSignOut: _signOut,
      );
    }

    return _SectionPlaceholder(index: _currentIndex);
  }
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
