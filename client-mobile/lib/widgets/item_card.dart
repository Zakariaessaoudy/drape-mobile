import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/item_model.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
  });

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    switch (item.imageStatus) {
      case 'FAILED':
        return Container(
          color: const Color(0xFFE0E0E0),
          alignment: Alignment.center,
          child: const Icon(
            Icons.error_outline,
            color: Colors.grey,
            size: 34,
          ),
        );
      case 'READY':
        if (item.imageUrl == null || item.imageUrl!.isEmpty) {
          return _buildCardFallback();
        }
        return CachedNetworkImage(
          imageUrl: item.imageUrl!,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _buildCardFallback(),
        );
      case 'PROCESSING':
      case 'PENDING':
      default:
        return Shimmer.fromColors(
          baseColor: const Color(0xFFD8D8D8),
          highlightColor: const Color(0xFFF1F1F1),
          child: Container(color: const Color(0xFFE6E6E6)),
        );
    }
  }

  Widget _buildCardFallback() {
    return Container(
      color: const Color(0xFFF0F0F0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 34,
      ),
    );
  }
}
