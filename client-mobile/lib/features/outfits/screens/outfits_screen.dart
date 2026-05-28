import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/camera/widgets/image_placeholder.dart';
import 'package:client_mobile/features/camera/widgets/signed_item_image.dart';
import 'package:client_mobile/features/outfits/data/outfit_api.dart';
import 'package:client_mobile/features/outfits/models/outfit.dart';
import 'package:flutter/material.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  late Future<List<Outfit>> _outfitsFuture;
  final _outfitApi = OutfitApi();

  @override
  void initState() {
    super.initState();
    _outfitsFuture = _outfitApi.fetchOutfits();
  }

  Future<void> _refresh() async {
    final nextOutfits = _outfitApi.fetchOutfits();
    setState(() {
      _outfitsFuture = nextOutfits;
    });
    await nextOutfits;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Outfit>>(
      future: _outfitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AuthColors.neon),
          );
        }

        if (snapshot.hasError) {
          return _MessageState(
            message: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }

        final outfits = snapshot.data ?? const [];
        if (outfits.isEmpty) {
          return _MessageState(
            message: 'No saved outfits yet.',
            onRetry: _refresh,
          );
        }

        return RefreshIndicator(
          color: AuthColors.neon,
          backgroundColor: Colors.black,
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
            itemCount: outfits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _OutfitCard(outfit: outfits[index]);
            },
          ),
        );
      },
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.outfit});

  final Outfit outfit;

  @override
  Widget build(BuildContext context) {
    final items = [outfit.top, outfit.bottom, outfit.shoe]
        .whereType<OutfitItem>()
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            outfit.name.isEmpty ? 'Saved Outfit' : outfit.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
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
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? SignedItemImage(imageUrl: item.imageUrl!)
              : ImagePlaceholder(text: item.category),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

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
            const Icon(Icons.style_outlined, color: AuthColors.neon, size: 42),
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
