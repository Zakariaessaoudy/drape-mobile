import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/outfits/models/outfit.dart';
import 'package:client_mobile/features/outfits/state/outfit_list_controller.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:client_mobile/features/wardrobe/widgets/cached_wardrobe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(outfitListControllerProvider.notifier).loadIfNeeded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outfitListControllerProvider);
    final controller = ref.read(outfitListControllerProvider.notifier);

    return RefreshIndicator(
      color: AuthColors.neon,
      backgroundColor: Colors.black,
      onRefresh: controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
        children: [
          _BuildOutfitButton(
            onTap: () => Navigator.of(context).pushNamed('/outfit-builder'),
          ),
          const SizedBox(height: 18),
          if (state.loading && state.outfits.isEmpty)
            const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(color: AuthColors.neon),
              ),
            )
          else if (state.error != null && state.outfits.isEmpty)
            _MessageState(message: state.error!, onRetry: controller.refresh)
          else if (state.outfits.isEmpty)
            _MessageState(
              message: 'No saved outfits yet.',
              onRetry: controller.refresh,
            )
          else
            for (final outfit in state.outfits) ...[
              _OutfitCard(
                outfit: outfit,
                onDelete: () => controller.deleteOutfit(outfit.id),
              ),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

class _BuildOutfitButton extends StatelessWidget {
  const _BuildOutfitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'BUILD OUTFIT',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.neon,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.outfit, required this.onDelete});

  final Outfit outfit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final items = [
      outfit.top,
      outfit.bottom,
      outfit.shoe,
    ].whereType<OutfitItem>().toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  outfit.name.isEmpty ? 'Saved Outfit' : outfit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete outfit',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white54,
                  size: 21,
                ),
              ),
            ],
          ),
          if (outfit.description != null && outfit.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              outfit.description!,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              for (final item in items) ...[
                Expanded(child: _OutfitItemPreview(item: item)),
                if (item != items.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OutfitItemPreview extends StatelessWidget {
  const _OutfitItemPreview({required this.item});

  final OutfitItem item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: const Color(0xFFF4F4F4),
          child: CachedWardrobeImage(item: item.toWardrobeItem()),
        ),
      ),
    );
  }
}

extension on OutfitItem {
  WardrobeItem toWardrobeItem() {
    return WardrobeItem(
      id: id,
      name: name,
      category: category,
      color: color,
      imageUrl: imageUrl,
      imageStatus: imageStatus,
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.style_outlined,
                color: AuthColors.neon,
                size: 42,
              ),
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
      ),
    );
  }
}
