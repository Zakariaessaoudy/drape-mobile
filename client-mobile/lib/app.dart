import 'package:camera/camera.dart';
import 'package:client_mobile/features/auth/screens/login_screen.dart';
import 'package:client_mobile/features/auth/state/auth_controller.dart';
import 'package:client_mobile/features/camera/screens/smart_camera_screen.dart';
import 'package:client_mobile/features/navigation/screens/overlay_feature_screens.dart';
import 'package:client_mobile/features/outfits/screens/outfit_builder_screen.dart';
import 'package:client_mobile/features/outfits/screens/outfits_screen.dart';
import 'package:client_mobile/features/outfits/state/outfit_list_controller.dart';
import 'package:client_mobile/features/profile/screens/profile_screen.dart';
import 'package:client_mobile/features/wardrobe/screens/item_details_screen.dart';
import 'package:client_mobile/features/wardrobe/screens/wardrobe_screen.dart';
import 'package:client_mobile/features/wardrobe/state/wardrobe_controller.dart';
import 'package:client_mobile/shared/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrapeApp extends ConsumerWidget {
  const DrapeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Drape',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const _AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const _HomeScreen(),
        '/saved-outfits': (_) => const OutfitsScreen(),
        '/outfit-builder': (_) => const OutfitBuilderScreen(),
        FavoritesScreen.routeName: (_) => const FavoritesScreen(),
        StylePreferencesScreen.routeName: (_) => const StylePreferencesScreen(),
        ProcessingItemsScreen.routeName: (_) => const ProcessingItemsScreen(),
        UploadHistoryScreen.routeName: (_) => const UploadHistoryScreen(),
        WardrobeInsightsScreen.routeName: (_) => const WardrobeInsightsScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        HelpScreen.routeName: (_) => const HelpScreen(),
        ItemDetailsScreen.routeName: (context) {
          final itemId = ModalRoute.of(context)?.settings.arguments as String?;
          return ItemDetailsScreen(itemId: itemId ?? '');
        },
        '/profile': (context) => ProfileScreen(
          onOpenWardrobe: () => Navigator.of(context).pop(),
          onOpenOutfits: () =>
              Navigator.of(context).pushNamed('/saved-outfits'),
          onSignOut: () async {
            await ref.read(authControllerProvider.notifier).logout();
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

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).checkSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    if (auth.status == AuthStatus.checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC6F135)),
        ),
      );
    }

    return auth.status == AuthStatus.authenticated
        ? const _HomeScreen()
        : const LoginScreen();
  }
}

class _HomeScreen extends ConsumerStatefulWidget {
  const _HomeScreen();

  @override
  ConsumerState<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<_HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategoryFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wardrobeControllerProvider.notifier).loadIfNeeded();
      ref.read(outfitListControllerProvider.notifier).loadIfNeeded();
    });
  }

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
    await ref.read(authControllerProvider.notifier).logout();
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
