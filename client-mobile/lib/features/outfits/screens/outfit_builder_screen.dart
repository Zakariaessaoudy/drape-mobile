import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/outfit_builder_controller.dart';
import '../models/outfit_item_model.dart';
import '../models/slot_type.dart';
import '../widgets/save_outfit_sheet.dart';
import '../../camera/widgets/signed_item_image.dart';
class OutfitBuilderScreen extends StatelessWidget {
  const OutfitBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OutfitBuilderProvider(),
      child: const _OutfitBuilderBody(),
    );
  }
}

class _OutfitBuilderBody extends StatelessWidget {
  const _OutfitBuilderBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutfitBuilderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────
            _AppBar(),

            // ── 3 horizontal rows ────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  _ItemRow(slot: SlotType.tops, provider: provider),
                  _RowDivider(),
                  _ItemRow(slot: SlotType.bottoms, provider: provider),
                  _RowDivider(),
                  _ItemRow(slot: SlotType.shoes, provider: provider),
                ],
              ),
            ),

            // ── Save button ───────────────────────────────────────
            _SaveButton(provider: provider),
          ],
        ),
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            'DRAPE',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const Spacer(),
          Text(
            'BUILD OUTFIT',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single horizontal row ─────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.slot, required this.provider});

  final SlotType slot;
  final OutfitBuilderProvider provider;

  @override
  Widget build(BuildContext context) {
    final isLoading = provider.isLoadingSlot(slot);
    final error = provider.errorFor(slot);
    final items = provider.itemsFor(slot);
    final selected = provider.selectedItemFor(slot);
    final isActive = selected != null;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row header ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                // Neon dot when slot is filled
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFFD4FF00)
                        : const Color(0xFF2a2a2a),
                  ),
                ),
                Text(
                  slot.label,
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFFD4FF00)
                        : Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
                if (selected != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '— ${selected.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Horizontal scroll list ─────────────────────────────
          Expanded(
            child: _RowContent(
              slot: slot,
              provider: provider,
              isLoading: isLoading,
              error: error,
              items: items,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowContent extends StatelessWidget {
  const _RowContent({
    required this.slot,
    required this.provider,
    required this.isLoading,
    required this.error,
    required this.items,
  });

  final SlotType slot;
  final OutfitBuilderProvider provider;
  final bool isLoading;
  final String? error;
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFD4FF00),
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white24, size: 20),
            const SizedBox(height: 6),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => provider.retrySlot(slot),
              child: Text(
                'Retry',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: const Color(0xFFD4FF00),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No ${slot.label.toLowerCase()} found',
          style: const TextStyle(color: Colors.white24, fontSize: 11),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = provider.isSelected(slot, item.id);
        return _ItemCard(
          item: item,
          isSelected: isSelected,
          onTap: () => provider.selectItem(slot, item.id),
        );
      },
    );
  }
}

// ── Item card ──────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final Item item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Card width fixed — height fills the row
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4FF00)
                : const Color(0xFF2a2a2a),
            width: isSelected ? 2 : 0.5,
          ),
          color: isSelected
              ? const Color(0xFFD4FF00).withOpacity(0.06)
              : const Color(0xFF1a1a1a),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image — fills most of the card
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                child:
                SignedItemImage(
                  imageUrl: item.imageUrl,

                )
              ),
            ),

            // Name
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFD4FF00)
                            : Colors.white60,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFD4FF00),
                      size: 10,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row divider ────────────────────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: const Color(0xFF2a2a2a),
    );
  }
}

// ── Save button ────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.provider});
  final OutfitBuilderProvider provider;

  @override
  Widget build(BuildContext context) {
    final canSave = provider.canSave;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2a2a2a), width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canSave)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _hintText(provider),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canSave ? () => SaveOutfitSheet.show(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4FF00),
                disabledBackgroundColor: const Color(0xFF2a2a2a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_add_outlined,
                    color: canSave ? Colors.black : Colors.white24,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SAVE OUTFIT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: canSave ? Colors.black : Colors.white24,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hintText(OutfitBuilderProvider provider) {
    final missing = <String>[];
    if (provider.selectedItemFor(SlotType.tops) == null) missing.add('top');
    if (provider.selectedItemFor(SlotType.bottoms) == null) missing.add('bottom');
    if (provider.selectedItemFor(SlotType.shoes) == null) missing.add('shoes');
    if (missing.isEmpty) return '';
    return 'Select a ${missing.join(', ')} to continue';
  }
}