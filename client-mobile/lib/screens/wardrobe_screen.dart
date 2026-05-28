import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../features/camera/smart_camera_screen.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/drape_bottom_nav.dart';
import '../widgets/filter_row.dart';
import '../widgets/item_card.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().fetchItems();
    });
  }

  Future<void> _openCamera() async {
    // Get available cameras
    final cameras = await availableCameras();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SmartCameraScreen(cameras: cameras),
      ),
    );
  }

  Future<void> _openAddItemSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddItemSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              title: Text(
                'DRAPE',
                style: GoogleFonts.anton(
                  color: const Color(0xFFC6F135),
                  fontSize: 32,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: _currentTabIndex == 0
                      ? Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                FilterRow(
                                  selectedFilter: provider.selectedFilter,
                                  onFilterSelected: provider.setFilter,
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: _WardrobeGrid(provider: provider),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 20,
                              bottom: 90,
                              child: GestureDetector(
                                onTap: _openCamera,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC6F135),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF111111),
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _ComingSoonView(index: _currentTabIndex),
                ),
                DrapeBottomNav(
                  currentIndex: _currentTabIndex,
                  onTap: (index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WardrobeGrid extends StatelessWidget {
  const _WardrobeGrid({required this.provider});

  final WardrobeProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6F135)),
        ),
      );
    }

    if (provider.errorMessage != null && provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFC6F135),
      backgroundColor: Colors.black,
      onRefresh: () => provider.fetchItems(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          return ItemCard(item: provider.items[index]);
        },
      ),
    );
  }
}

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.index});

  final int index;

  static const List<IconData> _icons = <IconData>[
    Icons.checkroom,
    Icons.auto_awesome,
    Icons.local_fire_department,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icons[index], color: Colors.white, size: 42),
          const SizedBox(height: 12),
          const Text(
            'Coming Soon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
