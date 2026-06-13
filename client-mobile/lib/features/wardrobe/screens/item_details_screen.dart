import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:client_mobile/features/wardrobe/state/wardrobe_controller.dart';
import 'package:client_mobile/features/wardrobe/widgets/cached_wardrobe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({super.key, required this.itemId});

  static const routeName = '/item-details';

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(
      wardrobeControllerProvider.select((state) {
        for (final current in state.items) {
          if (current.id == itemId) return current;
        }
        return null;
      }),
    );

    if (item == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Text(
              'Item not found.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Item Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            AspectRatio(
              aspectRatio: 0.86,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  color: const Color(0xFFF4F4F4),
                  padding: const EdgeInsets.all(16),
                  child: CachedWardrobeImage(item: item, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'CATEGORY', value: item.category),
            _InfoRow(label: 'COLOR', value: item.color),
            _InfoRow(label: 'IMAGE STATUS', value: item.imageStatus),
            const SizedBox(height: 26),
            _DeleteButton(item: item),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AuthColors.neon,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmDelete(context, ref),
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('DELETE ITEM'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF6B6B),
          side: const BorderSide(color: Color(0xFFFF6B6B)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
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

    if (success) {
      Navigator.of(context).pop();
    }
  }
}
