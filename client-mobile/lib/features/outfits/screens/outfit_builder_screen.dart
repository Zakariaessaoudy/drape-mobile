import 'package:client_mobile/features/outfits/state/outfit_builder_controller.dart';
import 'package:client_mobile/features/outfits/state/outfit_list_controller.dart';
import 'package:client_mobile/features/outfits/widgets/outfit_item_carousel.dart';
import 'package:client_mobile/features/wardrobe/state/wardrobe_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  static const _canvasColor = Color(0xFFF2F0E8);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(wardrobeControllerProvider.notifier).loadIfNeeded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final builder = ref.watch(outfitBuilderControllerProvider);

    return Scaffold(
      backgroundColor: _canvasColor,
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: Column(
                children: [
                  _ItemRow(slot: OutfitSlot.top),
                  _ItemRow(slot: OutfitSlot.bottom),
                  _ItemRow(slot: OutfitSlot.shoe),
                ],
              ),
            ),
            _SaveButton(canSave: builder.canSave),
          ],
        ),
      ),
    );
  }
}

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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            'DRAPE',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 4,
            ),
          ),
          const Spacer(),
          Text(
            'BUILD OUTFIT',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: Colors.black45,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({required this.slot});

  final OutfitSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobe = ref.watch(wardrobeControllerProvider);
    final builder = ref.watch(outfitBuilderControllerProvider);
    final controller = ref.read(outfitBuilderControllerProvider.notifier);
    final items = ref.watch(outfitSlotItemsProvider(slot));
    final selectedId = builder.selectedIdFor(slot);

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (wardrobe.loading && !wardrobe.loaded) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFB6F000),
                      ),
                    ),
                  );
                }

                if (wardrobe.error != null && items.isEmpty) {
                  return _RowErrorState(
                    message: wardrobe.error!,
                    onRetry: () =>
                        ref.read(wardrobeControllerProvider.notifier).refresh(),
                  );
                }

                return OutfitItemCarousel(
                  categoryLabel: slot.label,
                  items: items,
                  selectedItemId: selectedId,
                  height: constraints.maxHeight,
                  imageScale: slot == OutfitSlot.bottom ? 1.18 : 1.08,
                  onSelected: (item) {
                    if (selectedId == item.id) return;
                    controller.selectItem(slot, item.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RowErrorState extends StatelessWidget {
  const _RowErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: Colors.black26, size: 20),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onRetry,
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
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.canSave});

  final bool canSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canSave)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Select a top, bottom, and shoes to continue',
                style: TextStyle(color: Colors.black45, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: canSave ? () => _SaveOutfitSheet.show(context) : null,
              icon: Icon(
                Icons.bookmark_add_outlined,
                color: canSave ? Colors.black : Colors.white24,
                size: 18,
              ),
              label: Text(
                'SAVE OUTFIT',
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: canSave ? Colors.black : Colors.white24,
                  letterSpacing: 2.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4FF00),
                disabledBackgroundColor: const Color(0xFF2F2F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveOutfitSheet extends ConsumerStatefulWidget {
  const _SaveOutfitSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SaveOutfitSheet(),
    );
  }

  @override
  ConsumerState<_SaveOutfitSheet> createState() => _SaveOutfitSheetState();
}

class _SaveOutfitSheetState extends ConsumerState<_SaveOutfitSheet> {
  final _nameController = TextEditingController(text: 'My Outfit');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final builder = ref.read(outfitBuilderControllerProvider);
    final builderController = ref.read(
      outfitBuilderControllerProvider.notifier,
    );
    final outfitController = ref.read(outfitListControllerProvider.notifier);

    builderController.setSaving(true);
    final success = await outfitController.createOutfit(
      name: name,
      description: _descriptionController.text,
      topId: builder.selectedTopId!,
      bottomId: builder.selectedBottomId!,
      shoeId: builder.selectedShoeId!,
    );

    if (!mounted) return;

    builderController.setSaving(false);
    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context).maybePop();
    } else {
      builderController.setError(
        ref.read(outfitListControllerProvider).error ?? 'Could not save outfit',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final builder = ref.watch(outfitBuilderControllerProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Save Outfit',
              style: GoogleFonts.spaceMono(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Give your outfit a name',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _DarkTextField(
              controller: _nameController,
              hintText: 'Outfit name...',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _DarkTextField(
              controller: _descriptionController,
              hintText: 'Description (optional)...',
            ),
            if (builder.error != null) ...[
              const SizedBox(height: 12),
              Text(
                builder.error!,
                style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: builder.isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF00),
                  disabledBackgroundColor: const Color(
                    0xFFD4FF00,
                  ).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: builder.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'SAVE',
                        style: GoogleFonts.spaceMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 2,
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

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hintText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: const Color(0xFFD4FF00),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4FF00), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
