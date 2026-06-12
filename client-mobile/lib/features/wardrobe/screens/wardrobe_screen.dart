import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:client_mobile/features/wardrobe/state/wardrobe_controller.dart';
import 'package:client_mobile/features/wardrobe/widgets/cached_wardrobe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({
    super.key,
    required this.selectedFilter,
    this.onAddItem,
  });

  final String selectedFilter;
  final VoidCallback? onAddItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobe = ref.watch(wardrobeControllerProvider);
    final items = wardrobe.byCategory(selectedFilter);

    return Stack(
      children: [
        _WardrobeContent(
          loading: wardrobe.loading,
          error: wardrobe.error,
          items: items,
          onRefresh: () =>
              ref.read(wardrobeControllerProvider.notifier).refresh(),
        ),
        if (onAddItem != null)
          Positioned(
            right: 22,
            bottom: 24,
            child: GestureDetector(
              onTap: onAddItem,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AuthColors.neon,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AuthColors.neon.withValues(alpha: 0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 34),
              ),
            ),
          ),
      ],
    );
  }
}

class _WardrobeContent extends StatelessWidget {
  const _WardrobeContent({
    required this.loading,
    required this.error,
    required this.items,
    required this.onRefresh,
  });

  final bool loading;
  final String? error;
  final List<WardrobeItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AuthColors.neon),
      );
    }

    if (error != null && items.isEmpty) {
      return _MessageState(
        icon: Icons.error_outline,
        message: error!,
        onRetry: onRefresh,
      );
    }

    if (items.isEmpty) {
      return _MessageState(
        icon: Icons.checkroom_outlined,
        message: 'No items found for this filter.',
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      color: AuthColors.neon,
      backgroundColor: Colors.black,
      onRefresh: onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 22,
          childAspectRatio: 0.84,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _WardrobeItemCard(item: items[index]);
        },
      ),
    );
  }
}

class _WardrobeItemCard extends ConsumerWidget {
  const _WardrobeItemCard({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0xFFF4F4F4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CachedWardrobeImage(item: item, fit: BoxFit.contain),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _DeleteItemButton(
                onTap: () => _confirmDelete(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              title: const Text(
                'Delete item?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Text(
                'Remove "${item.name}" from your wardrobe?',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final success = await ref
        .read(wardrobeControllerProvider.notifier)
        .deleteItem(item.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Item deleted.' : 'Could not delete item.'),
      ),
    );
  }
}

class _DeleteItemButton extends StatelessWidget {
  const _DeleteItemButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Delete item',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFFF6B6B),
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AuthColors.neon, size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: AuthColors.neon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
