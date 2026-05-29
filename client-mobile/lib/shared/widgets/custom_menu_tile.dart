import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomMenuTile extends StatefulWidget {
  const CustomMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;
  final Widget? trailing;
  final bool destructive;

  @override
  State<CustomMenuTile> createState() => _CustomMenuTileState();
}

class _CustomMenuTileState extends State<CustomMenuTile> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.destructive
        ? const Color(0xFFFF6B6B)
        : AuthColors.neon;

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _highlighted
              ? const Color(0xFF191919)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _highlighted
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.14),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onHighlightChanged: (value) {
              setState(() {
                _highlighted = value;
              });
            },
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: _highlighted ? 1.06 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _highlighted
                              ? accentColor.withValues(alpha: 0.48)
                              : Colors.white.withValues(alpha: 0.03),
                        ),
                        boxShadow: _highlighted
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.18),
                                  blurRadius: 16,
                                ),
                              ]
                            : const [],
                      ),
                      child: Icon(widget.icon, color: accentColor, size: 19),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.destructive
                            ? const Color(0xFFFF8A8A)
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                  widget.trailing ??
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _highlighted
                            ? accentColor
                            : Colors.white.withValues(alpha: 0.55),
                        size: 22,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
