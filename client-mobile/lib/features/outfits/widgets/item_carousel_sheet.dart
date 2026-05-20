import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/outfit_builder_controller.dart';
import '../models/outfit_item_model.dart';
import '../models/slot_type.dart';
/*

class ItemCarouselSheet extends StatelessWidget {
  final SlotType slot;

  const ItemCarouselSheet({super.key, required this.slot});

  static Future<void> show(BuildContext context, SlotType slot) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemCarouselSheet(slot: slot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutfitBuilderProvider>();
    final items = provider.itemsFor(slot);
    final selectedIdx = provider.selectedIndexFor(slot);

    return Container(
      height: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIdx;
                return _ItemCard(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    context.read<OutfitBuilderProvider>().selectItem(slot, index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  Color _parse(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4FF00)
                : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Item preview — color swatch or image
            item.imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _ColorSwatch(item.color),
              ),
            )
                : _ColorSwatch(item.color),
            const SizedBox(height: 10),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.3,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              const Icon(Icons.check_circle, color: Color(0xFFD4FF00), size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String hex;
  const _ColorSwatch(this.hex);

  Color _parse(String h) {
    final cleaned = h.replaceAll('#', '');
    if (cleaned.length == 6) return Color(int.parse('FF$cleaned', radix: 16));
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _parse(hex),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}*/