// Darija: Had screen test/debug bach nt2ekdo wach AI w Wardrobe kmlou lkhedma:
// kayjib items, kaybeyn status, w kayaffichi images b signed URL.
import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:client_mobile/features/camera/models/camera_item.dart';
import 'package:client_mobile/features/camera/models/camera_item_counts.dart';
import 'package:client_mobile/features/camera/state/item_fetch_controller.dart';
import 'package:client_mobile/features/camera/widgets/image_placeholder.dart';
import 'package:client_mobile/features/camera/widgets/signed_item_image.dart';
import 'package:client_mobile/features/camera/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemFetchTestScreen extends StatelessWidget {
  const ItemFetchTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemFetchController()..load(),
      child: const _ItemFetchTestView(),
    );
  }
}

class _ItemFetchTestView extends StatelessWidget {
  const _ItemFetchTestView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ItemFetchController>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Item Fetch Test'),
            Text(
              ApiConstants.wardrobeBaseUrl,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: context.read<ItemFetchController>().load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _Body(controller: controller),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final ItemFetchController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return _ErrorState(message: controller.error!);
    }

    if (controller.items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return RefreshIndicator(
      onRefresh: context.read<ItemFetchController>().load,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Summary(counts: controller.counts),
          const SizedBox(height: 12),
          for (final item in controller.items) _ItemCard(item: item),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.counts});

  final CameraItemCounts counts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Count(label: 'TOTAL', value: counts.total),
            _Count(label: 'READY', value: counts.ready),
            _Count(label: 'PROCESSING', value: counts.processing),
            _Count(label: 'FAILED', value: counts.failed),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1.2)),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final CameraItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: item.hasImage
                ? SignedItemImage(imageUrl: item.imageUrl!)
                : ImagePlaceholder(text: 'No image yet: ${item.imageStatus}'),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    StatusPill(status: item.imageStatus),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${item.category} / ${item.color}'),
                const SizedBox(height: 8),
                Text(
                  item.id,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
                if (item.hasImage) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.imageUrl!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
