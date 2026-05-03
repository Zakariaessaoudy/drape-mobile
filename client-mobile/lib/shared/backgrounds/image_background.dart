import 'package:flutter/material.dart';

class ImageBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const ImageBackground({
    super.key,
    required this.child,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            // ignore: deprecated_member_use
            Colors.black.withOpacity(0.3), // darken the image
            BlendMode.darken,
          ),
          image: AssetImage(imagePath),
          fit: BoxFit.cover, // fills entire screen
        ),
      ),
      child: child,
    );
  }
}