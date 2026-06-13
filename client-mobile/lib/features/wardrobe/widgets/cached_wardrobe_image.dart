import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camera/widgets/image_placeholder.dart';
import '../../camera/widgets/signed_item_image.dart';
import '../models/wardrobe_item.dart';
import '../state/wardrobe_controller.dart';

class CachedWardrobeImage extends ConsumerWidget {
  const CachedWardrobeImage({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
  });

  final WardrobeItem item;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localPath = ref.watch(
      wardrobeControllerProvider.select(
        (state) => state.localImagePathFor(item.id),
      ),
    );

    if (localPath != null && File(localPath).existsSync()) {
      return Image.file(
        File(localPath),
        fit: fit,
        errorBuilder: (_, _, _) => _fallbackImage(),
      );
    }

    return _fallbackImage();
  }

  Widget _fallbackImage() {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return SignedItemImage(imageUrl: item.imageUrl!, fit: fit);
    }

    if (item.imageStatus.toUpperCase() == 'PROCESSING') {
      return const _SimpleImageLoader();
    }

    return ImagePlaceholder(
      text: item.imageStatus.isEmpty ? item.category : item.imageStatus,
    );
  }
}

class _SimpleImageLoader extends StatelessWidget {
  const _SimpleImageLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
      ),
    );
  }
}
