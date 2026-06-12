import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/outfits/state/outfit_list_controller.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:client_mobile/features/wardrobe/state/wardrobe_controller.dart';
import 'package:client_mobile/features/wardrobe/widgets/cached_wardrobe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const routeName = '/favorites';

  @override
  Widget build(BuildContext context) {
    return const _FeaturePageShell(
      title: 'Favorites',
      subtitle: 'Pieces you want ready for your next look.',
      child: Column(
        children: [
          _InfoBanner(
            icon: Icons.favorite_outline,
            title: 'Your moodboard is taking shape',
            description:
                'Save standout pieces here to build outfits faster and keep your best picks close.',
          ),
          SizedBox(height: 18),
          _TwoColumnCards(
            leftTitle: 'Street Essentials',
            leftCaption: 'Black leather, washed denim, silver accents.',
            rightTitle: 'Weekend Capsule',
            rightCaption: 'Soft neutrals, clean basics, bright sneakers.',
          ),
        ],
      ),
    );
  }
}

class StylePreferencesScreen extends StatefulWidget {
  const StylePreferencesScreen({super.key});

  static const routeName = '/style-preferences';

  @override
  State<StylePreferencesScreen> createState() => _StylePreferencesScreenState();
}

class _StylePreferencesScreenState extends State<StylePreferencesScreen> {
  final Set<String> _selectedStyles = {'Minimal', 'Streetwear'};
  bool _smartRecommendations = true;
  bool _seasonalDrops = false;

  static const _styles = [
    'Minimal',
    'Streetwear',
    'Monochrome',
    'Tailored',
    'Sport Luxe',
    'Vintage',
  ];

  @override
  Widget build(BuildContext context) {
    return _FeaturePageShell(
      title: 'Style Preferences',
      subtitle: 'Tune DRAPE to the looks you actually want to wear.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Preferred Aesthetic'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _styles.map((style) {
              final selected = _selectedStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: selected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedStyles.remove(style);
                    } else {
                      _selectedStyles.add(style);
                    }
                  });
                },
                selectedColor: AuthColors.neon.withValues(alpha: 0.18),
                checkmarkColor: AuthColors.neon,
                backgroundColor: const Color(0xFF151515),
                side: BorderSide(
                  color: selected
                      ? AuthColors.neon.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
                labelStyle: TextStyle(
                  color: selected ? AuthColors.neon : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),
          const _SectionLabel('Experience'),
          const SizedBox(height: 12),
          _PreferenceSwitchTile(
            icon: Icons.auto_awesome,
            title: 'Smart recommendations',
            subtitle: 'Get outfit ideas based on saved items and favorites.',
            value: _smartRecommendations,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _smartRecommendations = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _PreferenceSwitchTile(
            icon: Icons.bolt,
            title: 'Seasonal drop alerts',
            subtitle: 'Highlight new trends and seasonal recommendations.',
            value: _seasonalDrops,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _seasonalDrops = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ProcessingItemsScreen extends ConsumerStatefulWidget {
  const ProcessingItemsScreen({super.key});

  static const routeName = '/processing-items';

  @override
  ConsumerState<ProcessingItemsScreen> createState() =>
      _ProcessingItemsScreenState();
}

class _ProcessingItemsScreenState extends ConsumerState<ProcessingItemsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wardrobeControllerProvider.notifier).loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeControllerProvider);

    return _ListPageShell<WardrobeItem>(
      title: 'Processing Items',
      subtitle: 'Track uploads that are still being cleaned and prepared.',
      loading: wardrobe.loading && !wardrobe.loaded,
      error: wardrobe.error,
      items: wardrobe.processingItems,
      onRefresh: ref.read(wardrobeControllerProvider.notifier).refresh,
      emptyIcon: Icons.hourglass_top_rounded,
      emptyMessage: 'Nothing is processing right now.',
      itemBuilder: (context, items) {
        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StatusCard(
                    icon: Icons.blur_circular,
                    title: item.name,
                    subtitle:
                        '${item.category} - ${item.color.isEmpty ? 'Color pending' : item.color}',
                    status: item.imageStatus,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class UploadHistoryScreen extends ConsumerStatefulWidget {
  const UploadHistoryScreen({super.key});

  static const routeName = '/upload-history';

  @override
  ConsumerState<UploadHistoryScreen> createState() =>
      _UploadHistoryScreenState();
}

class _UploadHistoryScreenState extends ConsumerState<UploadHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wardrobeControllerProvider.notifier).loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeControllerProvider);

    return _ListPageShell<WardrobeItem>(
      title: 'Upload History',
      subtitle: 'Every wardrobe item that has been scanned into DRAPE.',
      loading: wardrobe.loading && !wardrobe.loaded,
      error: wardrobe.error,
      items: wardrobe.items,
      onRefresh: ref.read(wardrobeControllerProvider.notifier).refresh,
      emptyIcon: Icons.history_toggle_off,
      emptyMessage: 'Your upload history will show up here.',
      itemBuilder: (context, items) {
        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _UploadHistoryCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class WardrobeInsightsScreen extends ConsumerStatefulWidget {
  const WardrobeInsightsScreen({super.key});

  static const routeName = '/wardrobe-insights';

  @override
  ConsumerState<WardrobeInsightsScreen> createState() =>
      _WardrobeInsightsScreenState();
}

class _WardrobeInsightsScreenState
    extends ConsumerState<WardrobeInsightsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wardrobeControllerProvider.notifier).loadIfNeeded();
      ref.read(outfitListControllerProvider.notifier).loadIfNeeded();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(wardrobeControllerProvider.notifier).refresh(),
      ref.read(outfitListControllerProvider.notifier).refresh(),
    ]);
  }

  _InsightData _buildInsights() {
    final items = ref.watch(wardrobeControllerProvider).items;
    final outfits = ref.watch(outfitListControllerProvider).outfits;
    int countByCategory(String category) {
      return items.where((item) => item.category == category).length;
    }

    return _InsightData(
      itemCount: items.length,
      outfitCount: outfits.length,
      topCount: countByCategory('TOP'),
      bottomCount: countByCategory('BOTTOM'),
      shoeCount: countByCategory('SHOE'),
      readyCount: items
          .where((item) => item.imageStatus.toUpperCase() == 'READY')
          .length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeControllerProvider);
    final outfitList = ref.watch(outfitListControllerProvider);
    final loading =
        (wardrobe.loading && !wardrobe.loaded) ||
        (outfitList.loading && !outfitList.loaded);
    final error = wardrobe.error ?? outfitList.error;

    if (loading) {
      return const _FeaturePageShell(
        title: 'Wardrobe Insights',
        subtitle: 'A quick read on the balance and health of your closet.',
        child: SizedBox(height: 220, child: _FeatureLoadingView()),
      );
    }

    if (error != null && wardrobe.items.isEmpty && outfitList.outfits.isEmpty) {
      return _FeaturePageShell(
        title: 'Wardrobe Insights',
        subtitle: 'A quick read on the balance and health of your closet.',
        child: _FeatureEmptyState(
          icon: Icons.analytics_outlined,
          message: error,
          buttonLabel: 'Retry',
          onPressed: _refresh,
        ),
      );
    }

    final data = _buildInsights();

    return _FeaturePageShell(
      title: 'Wardrobe Insights',
      subtitle: 'A quick read on the balance and health of your closet.',
      child: RefreshIndicator(
        color: AuthColors.neon,
        backgroundColor: Colors.black,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: _InsightStatCard(
                    value: '${data.itemCount}',
                    label: 'ITEMS',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightStatCard(
                    value: '${data.outfitCount}',
                    label: 'OUTFITS',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightStatCard(
                    value: '${data.readyCount}',
                    label: 'READY',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Category Balance'),
            const SizedBox(height: 12),
            _InsightBreakdownCard(
              rows: [
                _BreakdownRowData('Tops', data.topCount),
                _BreakdownRowData('Bottoms', data.bottomCount),
                _BreakdownRowData('Shoes', data.shoeCount),
              ],
            ),
            const SizedBox(height: 18),
            const _InfoBanner(
              icon: Icons.bolt,
              title: 'Quick read',
              description:
                  'Your strongest styling leverage comes from balancing tops, bottoms, and statement footwear.',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return const _FeaturePageShell(
      title: 'Notifications',
      subtitle: 'Updates around uploads, outfit ideas, and wardrobe activity.',
      child: Column(
        children: [
          _StatusCard(
            icon: Icons.check_circle_outline,
            title: 'Your latest item is ready',
            subtitle: 'Background removal finished and your item is live.',
            status: 'LIVE',
          ),
          SizedBox(height: 14),
          _StatusCard(
            icon: Icons.auto_awesome,
            title: 'New outfit suggestions',
            subtitle: 'DRAPE generated a fresh pairing from your saved pieces.',
            status: 'NEW',
          ),
          SizedBox(height: 14),
          _StatusCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Style trend alert',
            subtitle: 'Minimal monochrome edits are trending this week.',
            status: 'TREND',
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _wifiUploadsOnly = false;
  bool _autoRefreshImages = true;

  @override
  Widget build(BuildContext context) {
    return _FeaturePageShell(
      title: 'Settings',
      subtitle: 'Fine-tune uploads, notifications, and app behavior.',
      child: Column(
        children: [
          _PreferenceSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push notifications',
            subtitle: 'Get alerts when items finish processing.',
            value: _pushEnabled,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _pushEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _PreferenceSwitchTile(
            icon: Icons.wifi,
            title: 'Upload on Wi-Fi only',
            subtitle: 'Keep image uploads limited to stable connections.',
            value: _wifiUploadsOnly,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _wifiUploadsOnly = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _PreferenceSwitchTile(
            icon: Icons.image_search_outlined,
            title: 'Auto refresh processed images',
            subtitle: 'Refresh generated item images when they are ready.',
            value: _autoRefreshImages,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _autoRefreshImages = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const routeName = '/help';

  @override
  Widget build(BuildContext context) {
    return const _FeaturePageShell(
      title: 'Help',
      subtitle: 'Answers for uploads, processing, and everyday app use.',
      child: Column(
        children: [
          _FaqCard(
            question: 'Why is my item still processing?',
            answer:
                'Large images or slow processing can take longer. Refresh the wardrobe or check Processing Items for status updates.',
          ),
          SizedBox(height: 14),
          _FaqCard(
            question: 'Why did an item disappear from a filter?',
            answer:
                'Items only appear inside matching categories. Switch back to ALL to confirm the item is still in your wardrobe.',
          ),
          SizedBox(height: 14),
          _FaqCard(
            question: 'How do I get cleaner cutouts?',
            answer:
                'Use clear lighting, keep the item centered, and avoid cluttered backgrounds when capturing new images.',
          ),
        ],
      ),
    );
  }
}

class _FeaturePageShell extends StatelessWidget {
  const _FeaturePageShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListPageShell<T> extends StatelessWidget {
  const _ListPageShell({
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.error,
    required this.items,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final String title;
  final String subtitle;
  final bool loading;
  final String? error;
  final List<T> items;
  final Future<void> Function() onRefresh;
  final IconData emptyIcon;
  final String emptyMessage;
  final Widget Function(BuildContext context, List<T> items) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: const _FeatureLoadingView(),
      );
    }

    if (error != null && items.isEmpty) {
      return _FeaturePageShell(
        title: title,
        subtitle: subtitle,
        child: _FeatureEmptyState(
          icon: emptyIcon,
          message: error!,
          buttonLabel: 'Retry',
          onPressed: onRefresh,
        ),
      );
    }

    return _FeaturePageShell(
      title: title,
      subtitle: subtitle,
      child: items.isEmpty
          ? _FeatureEmptyState(
              icon: emptyIcon,
              message: emptyMessage,
              buttonLabel: 'Refresh',
              onPressed: onRefresh,
            )
          : RefreshIndicator(
              color: AuthColors.neon,
              backgroundColor: Colors.black,
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [itemBuilder(context, items)],
              ),
            ),
    );
  }
}

class _FeatureLoadingView extends StatelessWidget {
  const _FeatureLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AuthColors.neon),
    );
  }
}

class _FeatureEmptyState extends StatelessWidget {
  const _FeatureEmptyState({
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String buttonLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AuthColors.neon),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onPressed,
            child: Text(
              buttonLabel,
              style: TextStyle(
                color: AuthColors.neon,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    final accent = switch (status.toUpperCase()) {
      'FAILED' => const Color(0xFFFF6B6B),
      'PROCESSING' => const Color(0xFFFFC857),
      _ => AuthColors.neon,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusPill(label: status, color: accent),
        ],
      ),
    );
  }
}

class _UploadHistoryCard extends StatelessWidget {
  const _UploadHistoryCard({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 78,
                height: 96,
                child: CachedWardrobeImage(item: item),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.category} - ${item.color}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatusPill(
                    label: item.imageStatus,
                    color: _statusColor(item.imageStatus),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PROCESSING':
        return const Color(0xFFFFC857);
      case 'FAILED':
        return const Color(0xFFFF6B6B);
      default:
        return AuthColors.neon;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AuthColors.neon.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AuthColors.neon.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AuthColors.neon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TwoColumnCards extends StatelessWidget {
  const _TwoColumnCards({
    required this.leftTitle,
    required this.leftCaption,
    required this.rightTitle,
    required this.rightCaption,
  });

  final String leftTitle;
  final String leftCaption;
  final String rightTitle;
  final String rightCaption;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStoryCard(title: leftTitle, caption: leftCaption),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStoryCard(title: rightTitle, caption: rightCaption),
        ),
      ],
    );
  }
}

class _MiniStoryCard extends StatelessWidget {
  const _MiniStoryCard({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AuthColors.neon),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceSwitchTile extends StatelessWidget {
  const _PreferenceSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AuthColors.neon.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AuthColors.neon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.black,
            activeTrackColor: AuthColors.neon,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }
}

class _InsightStatCard extends StatelessWidget {
  const _InsightStatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBreakdownCard extends StatelessWidget {
  const _InsightBreakdownCard({required this.rows});

  final List<_BreakdownRowData> rows;

  @override
  Widget build(BuildContext context) {
    final maxValue = rows.fold<int>(0, (current, row) {
      return row.value > current ? row.value : current;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: rows.map((row) {
          final fraction = maxValue == 0 ? 0.0 : row.value / maxValue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF232323),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AuthColors.neon,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${row.value}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: AuthColors.neon,
          iconColor: AuthColors.neon,
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              answer,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightData {
  const _InsightData({
    required this.itemCount,
    required this.outfitCount,
    required this.topCount,
    required this.bottomCount,
    required this.shoeCount,
    required this.readyCount,
  });

  final int itemCount;
  final int outfitCount;
  final int topCount;
  final int bottomCount;
  final int shoeCount;
  final int readyCount;
}

class _BreakdownRowData {
  const _BreakdownRowData(this.label, this.value);

  final String label;
  final int value;
}
