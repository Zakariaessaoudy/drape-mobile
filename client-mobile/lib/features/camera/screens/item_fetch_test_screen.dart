// Darija: Had screen test/debug bach nt2ekdo wach AI w Wardrobe kmlou lkhedma:
// kayjib items, kaybeyn status, w kayaffichi images b signed URL.
import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:client_mobile/features/camera/widgets/image_placeholder.dart';
import 'package:client_mobile/features/camera/widgets/status_pill.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:client_mobile/features/wardrobe/state/wardrobe_controller.dart';
import 'package:client_mobile/features/wardrobe/widgets/cached_wardrobe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemFetchTestScreen extends ConsumerStatefulWidget {
  const ItemFetchTestScreen({super.key});

  @override
  ConsumerState<ItemFetchTestScreen> createState() =>
      _ItemFetchTestScreenState();
}

class _ItemFetchTestScreenState extends ConsumerState<ItemFetchTestScreen> {
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
            onPressed: ref.read(wardrobeControllerProvider.notifier).refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _Body(
        loading: wardrobe.loading && !wardrobe.loaded,
        error: wardrobe.error,
        items: wardrobe.items,
        onRefresh: ref.read(wardrobeControllerProvider.notifier).refresh,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && items.isEmpty) {
      return _ErrorState(message: error!);
    }

    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Summary(counts: _ItemCounts.fromItems(items)),
          const SizedBox(height: 12),
          for (final item in items) _ItemCard(item: item),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.counts});

  final _ItemCounts counts;

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

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: hasImage
                ? CachedWardrobeImage(item: item)
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
                if (hasImage) ...[
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

class _ItemCounts {
  const _ItemCounts({
    required this.total,
    required this.ready,
    required this.processing,
    required this.failed,
  });

  final int total;
  final int ready;
  final int processing;
  final int failed;

  factory _ItemCounts.fromItems(List<WardrobeItem> items) {
    return _ItemCounts(
      total: items.length,
      ready: items
          .where((item) => item.imageStatus.toUpperCase() == 'READY')
          .length,
      processing: items
          .where((item) => item.imageStatus.toUpperCase() == 'PROCESSING')
          .length,
      failed: items
          .where((item) => item.imageStatus.toUpperCase() == 'FAILED')
          .length,
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
