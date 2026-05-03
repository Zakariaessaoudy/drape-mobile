import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class DrapeLogo extends StatelessWidget {
  const DrapeLogo({super.key, required this.size, required this.assetPath});

  final double size;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: size,
      width: size * 7.8,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'DRAPE',
      errorBuilder: (_, _, _) {
        return Text(
          'DRAPE',
          style: TextStyle(
            color: AuthColors.neon,
            fontSize: size,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -2,
          ),
        );
      },
    );
  }
}
