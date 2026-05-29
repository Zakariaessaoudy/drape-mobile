import 'package:flutter/material.dart';

class AnimatedPopupMenu extends StatelessWidget {
  const AnimatedPopupMenu({
    super.key,
    required this.child,
    required this.alignment,
    required this.margin,
    this.width,
    this.maxWidth = 340,
    this.height,
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets margin;
  final double? width;
  final double maxWidth;
  final double? height;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required String barrierLabel,
    required Alignment alignment,
    required Offset slideFrom,
    required EdgeInsets margin,
    double? width,
    double? height,
    double maxWidth = 340,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: barrierLabel,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, _, _) {
        return AnimatedPopupMenu(
          alignment: alignment,
          margin: margin,
          width: width,
          height: height,
          maxWidth: maxWidth,
          child: Builder(builder: builder),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: slideFrom,
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final popupWidth = width ?? (screenWidth < maxWidth ? screenWidth : maxWidth);

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: margin,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: popupWidth > maxWidth ? maxWidth : popupWidth,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E0E),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.42),
                    blurRadius: 34,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
