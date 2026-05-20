import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/slot_type.dart';


class SlotPill extends StatelessWidget {
  final SlotType slot;
  final int current;
  final int total;
  final bool active;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTap;

  const SlotPill({
    super.key,
    required this.slot,
    required this.current,
    required this.total,
    required this.active,
    required this.onPrev,
    required this.onNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.88),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: active
                ? const Color(0xFFD4FF00).withOpacity(0.6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
            const SizedBox(width: 6),
            Text(
              '${slot.label} ($current/$total)',
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD4FF00),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 6),
            _ArrowBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
          ],
        ),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(icon, color: const Color(0xFFD4FF00), size: 20),
      ),
    );
  }
}