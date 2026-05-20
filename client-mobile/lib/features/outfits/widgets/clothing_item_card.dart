// widgets/clothing_item_card.dart

import 'package:flutter/material.dart';
import '../models/outfit_item_model.dart';
import '../controllers/outfit_builder_controller.dart';
import 'drape_theme.dart';
/*
/// A draggable card displayed in the horizontal shelf.
/// Tapping the card places it directly on the mannequin.
/// Long-pressing or dragging starts a drag session.
class ClothingItemCard extends StatefulWidget {
  final OutfitItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final OutfitBuilderController  controller;

  const ClothingItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.controller,
  });

  @override
  State<ClothingItemCard> createState() => _ClothingItemCardState();
}

class _ClothingItemCardState extends State<ClothingItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<OutfitItem>(
      data: widget.item,
      onDragStarted: () => widget.controller.onDragStarted(widget.item),
      onDraggableCanceled: (_, __) => widget.controller.onDragCanceled(),
      onDragCompleted: () {},
      feedback: Material(
        color: Colors.transparent,
        child: _CardBody(
          item: widget.item,
          isSelected: widget.isSelected,
          scale: 1.15,
          isFeedback: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _CardBody(
          item: widget.item,
          isSelected: widget.isSelected,
          scale: 1.0,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.animateTo(0.92),
        onTapUp: (_) {
          _scaleCtrl.animateTo(1.0);
          widget.onTap();
        },
        onTapCancel: () => _scaleCtrl.animateTo(1.0),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: _CardBody(
            item: widget.item,
            isSelected: widget.isSelected,
            scale: 1.0,
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final OutfitItem item;
  final bool isSelected;
  final double scale;
  final bool isFeedback;

  const _CardBody({
    required this.item,
    required this.isSelected,
    required this.scale,
    this.isFeedback = false,
  });

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? DrapeColors.dark : DrapeColors.cardBg;
    final border = isSelected
        ? Border.all(color: DrapeColors.accent, width: 2)
        : Border.all(color: DrapeColors.divider, width: 1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 88,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(DrapeRadius.md),
        border: border,
        boxShadow: isFeedback || isSelected
            ? [
          BoxShadow(
            color: DrapeColors.dark.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Color swatch / item visual ─────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: DrapeRadius.md),
            child: item.imagePath != null
                ? Image.asset(
              item.imagePath!,
              width: 88,
              height: 72,
              fit: BoxFit.cover,
            )
                : item.imageUrl != null
                ? Image.network(
              item.imageUrl!,
              width: 88,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _ColorSwatch(hex: item.colorHex),
            )
                : _ColorSwatch(hex: item.colorHex),
          ),
          // ── Label ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: DrapeTextStyles.label.copyWith(
                    fontSize: 9,
                    color: isSelected
                        ? DrapeColors.white
                        : DrapeColors.textPrimary,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.price.toStringAsFixed(0)}',
                  style: DrapeTextStyles.price.copyWith(
                    fontSize: 9,
                    color: isSelected
                        ? DrapeColors.accent
                        : DrapeColors.textSecondary,
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

class _ColorSwatch extends StatelessWidget {
  final String hex;
  const _ColorSwatch({required this.hex});

  Color _parse() {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parse();
    final isLight =
        color.computeLuminance() > 0.5;

    return Container(
      width: 88,
      height: 72,
      color: color,
      child: Center(
        child: Icon(
          Icons.checkroom_outlined,
          color: (isLight ? Colors.black : Colors.white).withOpacity(0.25),
          size: 28,
        ),
      ),
    );
  }
}*/