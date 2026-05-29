import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/camera/widgets/image_placeholder.dart';
import 'package:client_mobile/features/camera/widgets/signed_item_image.dart';
import 'package:client_mobile/features/wardrobe/data/item_api.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:flutter/material.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({
    super.key,
    required this.selectedFilter,
    this.onAddItem,
  });

  final String selectedFilter;
  final VoidCallback? onAddItem;

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  late Future<List<WardrobeItem>> _itemsFuture;
  final _itemApi = ItemApi();

  @override
  void initState() {
    super.initState();
    _itemsFuture = _itemApi.fetchItems(category: widget.selectedFilter);
  }

  @override
  void didUpdateWidget(covariant WardrobeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter == widget.selectedFilter) return;

    _itemsFuture = _itemApi.fetchItems(category: widget.selectedFilter);
  }

  Future<void> _refresh() async {
    final nextItems = _itemApi.fetchItems(category: widget.selectedFilter);
    setState(() {
      _itemsFuture = nextItems;
    });
    await nextItems;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<WardrobeItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AuthColors.neon),
              );
            }

            if (snapshot.hasError) {
              return _MessageState(
                icon: Icons.error_outline,
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return _MessageState(
                icon: Icons.checkroom_outlined,
                message: 'No items found for this filter.',
                onRetry: _refresh,
              );
            }

            return RefreshIndicator(
              color: AuthColors.neon,
              backgroundColor: Colors.black,
              onRefresh: _refresh,
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
          },
        ),
        if (widget.onAddItem != null)
          Positioned(
            right: 22,
            bottom: 24,
            child: GestureDetector(
              onTap: widget.onAddItem,
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
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 34,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WardrobeItemCard extends StatelessWidget {
  const _WardrobeItemCard({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0xFFF4F4F4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? SignedItemImage(imageUrl: item.imageUrl!)
                  : ImagePlaceholder(text: item.imageStatus),
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
          ],
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
