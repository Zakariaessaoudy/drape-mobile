// Darija: Had widget kayaffichi item image:
// ila URL dyal S3 private, kayjib signed URL mn AI service 3ad kayloadiha.
import 'package:flutter/material.dart';

import '../api/signed_image_api.dart';
import 'image_placeholder.dart';

class SignedItemImage extends StatelessWidget {
  const SignedItemImage({
    super.key,
    required this.imageUrl,
    this.imageApi,
    this.fit = BoxFit.contain,
  });

  final String imageUrl;
  final SignedImageApi? imageApi;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: (imageApi ?? SignedImageApi()).displayUrlFor(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const ImagePlaceholder(text: 'Image unavailable.');
        }

        return Image.network(
          snapshot.data!,
          fit: fit,
          errorBuilder: (_, _, _) =>
              const ImagePlaceholder(text: 'Image unavailable.'),
        );
      },
    );
  }
}
