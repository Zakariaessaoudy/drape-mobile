// Darija: Had widget kayban f blasst image ila mazal makaynash URL
// ola ila image ma9dratch tloadi.
import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF151515),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
