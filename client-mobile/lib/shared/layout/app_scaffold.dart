import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/navigation/screens/overlay_feature_screens.dart';
import 'package:client_mobile/shared/widgets/animated_popup_menu.dart';
import 'package:client_mobile/shared/widgets/custom_menu_tile.dart';
import 'package:client_mobile/shared/widgets/drawer_section.dart';
import 'package:client_mobile/shared/widgets/drape_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.currentNavIndex,
    required this.onNavTap,
    this.showCategoryFilters = false,
    this.selectedCategoryFilter = 'ALL',
    this.onCategoryFilterChanged,
  });

  final Widget body;
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final bool showCategoryFilters;
  final String selectedCategoryFilter;
  final ValueChanged<String>? onCategoryFilterChanged;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _TopNavBar(
            showCategoryFilters: widget.showCategoryFilters,
            selectedFilter: widget.selectedCategoryFilter,
            onFilterChanged: widget.onCategoryFilterChanged,
            onMenuPressed: _showAppMenu,
            onProfilePressed: () => widget.onNavTap(3),
          ),
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: widget.currentNavIndex,
        onTap: widget.onNavTap,
      ),
    );
  }

  Future<void> _showAppMenu() async {
    HapticFeedback.selectionClick();
    await AnimatedPopupMenu.show<void>(
      context: context,
      barrierLabel: 'Dismiss main menu',
      alignment: Alignment.centerLeft,
      slideFrom: const Offset(-0.08, 0),
      margin: const EdgeInsets.fromLTRB(12, 18, 64, 18),
      width: 316,
      height: MediaQuery.sizeOf(context).height * 0.72,
      builder: (context) => _AppMenuContent(
        onSelected: (routeName) {
          Navigator.of(context).pop();
          _openRoute(routeName);
        },
      ),
    );
  }

  void _openRoute(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar({
    required this.showCategoryFilters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  final bool showCategoryFilters;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'Open main menu',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: AuthColors.neon),
                      onPressed: onMenuPressed,
                    ),
                  ),
                  const DrapeLogo(
                    size: 24,
                    assetPath: 'assets/images/drape_nobg.png',
                  ),
                  Semantics(
                    label: 'Open profile menu',
                    button: true,
                    child: IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: AuthColors.neon,
                      ),
                      onPressed: onProfilePressed,
                    ),
                  ),
                ],
              ),
            ),
            if (showCategoryFilters) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    _FilterDropdown(
                      label: 'ALL',
                      isSelected: selectedFilter == 'ALL',
                      onTap: () => onFilterChanged?.call('ALL'),
                    ),
                    const SizedBox(width: 14),
                    _FilterDropdown(
                      label: 'TOPS',
                      isSelected: selectedFilter == 'TOP',
                      onTap: () => onFilterChanged?.call('TOP'),
                    ),
                    const SizedBox(width: 14),
                    _FilterDropdown(
                      label: 'BOTTOMS',
                      isSelected: selectedFilter == 'BOTTOM',
                      onTap: () => onFilterChanged?.call('BOTTOM'),
                    ),
                    const SizedBox(width: 14),
                    _FilterDropdown(
                      label: 'SHOES',
                      isSelected: selectedFilter == 'SHOE',
                      onTap: () => onFilterChanged?.call('SHOE'),
                    ),
                  ],
                ),
              ),
            ],
            Divider(color: Colors.grey.shade900, height: 1),
          ],
        ),
      ),
    );
  }
}

class _AppMenuContent extends StatelessWidget {
  const _AppMenuContent({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AuthColors.neon.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_customize,
                  color: AuthColors.neon,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage processing, insights, and app tools.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DrawerSection(
                    title: 'Wardrobe Flow',
                    children: [
                      CustomMenuTile(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Processing Items',
                        semanticLabel: 'Open Processing Items',
                        onTap: () =>
                            onSelected(ProcessingItemsScreen.routeName),
                      ),
                      CustomMenuTile(
                        icon: Icons.history_rounded,
                        label: 'Upload History',
                        semanticLabel: 'Open Upload History',
                        onTap: () => onSelected(UploadHistoryScreen.routeName),
                      ),
                      CustomMenuTile(
                        icon: Icons.analytics_outlined,
                        label: 'Wardrobe Insights',
                        semanticLabel: 'Open Wardrobe Insights',
                        onTap: () =>
                            onSelected(WardrobeInsightsScreen.routeName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DrawerSection(
                    title: 'App',
                    children: [
                      CustomMenuTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifications',
                        semanticLabel: 'Open Notifications',
                        onTap: () => onSelected(NotificationsScreen.routeName),
                      ),
                      CustomMenuTile(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        semanticLabel: 'Open Settings',
                        onTap: () => onSelected(SettingsScreen.routeName),
                      ),
                      CustomMenuTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help',
                        semanticLabel: 'Open Help',
                        onTap: () => onSelected(HelpScreen.routeName),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isSelected) Icon(Icons.check, color: AuthColors.neon, size: 20),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected ? AuthColors.neon : Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItemData> _items = <_NavItemData>[
    _NavItemData(label: 'WARDROBE', icon: Icons.checkroom),
    _NavItemData(label: 'TRY-ON', icon: Icons.auto_awesome),
    _NavItemData(label: 'FEED', icon: Icons.local_fire_department),
    _NavItemData(label: 'PROFILE', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey.shade900, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    isActive
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AuthColors.neon,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: Colors.black),
                          )
                        : Icon(item.icon, color: Colors.white),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? AuthColors.neon : Colors.white,
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
