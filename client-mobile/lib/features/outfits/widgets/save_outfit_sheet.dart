import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/outfit_builder_controller.dart';

class SaveOutfitSheet extends StatefulWidget {
  const SaveOutfitSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<OutfitBuilderProvider>(),
        child: const SaveOutfitSheet(),
      ),
    );
  }

  @override
  State<SaveOutfitSheet> createState() => _SaveOutfitSheetState();
}

class _SaveOutfitSheetState extends State<SaveOutfitSheet> {
  final _nameCtrl = TextEditingController(text: 'My Outfit');
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(OutfitBuilderProvider provider) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final success = await provider.saveOutfit(
      name: name,
      description: _descCtrl.text.trim(),
    );

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutfitBuilderProvider>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            Text(
              'Give your outfit a name',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Outfit name
            _DarkTextField(
              controller: _nameCtrl,
              hintText: 'Outfit name...',
              autofocus: true,
            ),
            const SizedBox(height: 12),

            // Description (optionnel)
            _DarkTextField(
              controller: _descCtrl,
              hintText: 'Description (optional)...',
            ),

            // Error
            if (provider.saveError != null) ...[
              const SizedBox(height: 12),
              Text(
                provider.saveError!,
                style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: provider.saved
                  ? _SavedButton()
                  : ElevatedButton(
                      onPressed: provider.isSaving
                          ? null
                          : () => _save(provider),
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
                      child: provider.isSaving
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
        fillColor: const Color(0xFF2a2a2a),
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

class _SavedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFD4FF00), size: 18),
          const SizedBox(width: 8),
          Text(
            'SAVED',
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4FF00),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
