import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/wardrobe/models/wardrobe_item.dart';
import 'package:client_mobile/features/wardrobe/widgets/cached_wardrobe_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OutfitItemCarousel extends StatefulWidget {
  const OutfitItemCarousel({
    super.key,
    required this.categoryLabel,
    required this.items,
    required this.selectedItemId,
    required this.onSelected,
    this.height = 220,
  });

  final String categoryLabel;
  final List<WardrobeItem> items;
  final String? selectedItemId;
  final ValueChanged<WardrobeItem> onSelected;
  final double height;

  @override
  State<OutfitItemCarousel> createState() => _OutfitItemCarouselState();
}

class _OutfitItemCarouselState extends State<OutfitItemCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = _indexFor(widget.selectedItemId);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.58,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _selectFirstIfNeeded());
  }

  @override
  void didUpdateWidget(covariant OutfitItemCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.isEmpty) {
      _currentIndex = 0;
      return;
    }

    final nextIndex = _indexFor(widget.selectedItemId);
    if (nextIndex != _currentIndex) {
      _currentIndex = nextIndex;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _selectFirstIfNeeded());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectFirstIfNeeded() {
    if (!mounted || widget.items.isEmpty || widget.selectedItemId != null) {
      return;
    }
    widget.onSelected(widget.items.first);
  }

  int _indexFor(String? itemId) {
    if (widget.items.isEmpty || itemId == null) return 0;
    final index = widget.items.indexWhere((item) => item.id == itemId);
    return index == -1 ? 0 : index;
  }

  void _selectPage(int index) {
    if (index < 0 || index >= widget.items.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No ready ${widget.categoryLabel.toLowerCase()} yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ),
      );
    }

    final canGoBack = _currentIndex > 0;
    final canGoForward = _currentIndex < widget.items.length - 1;

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              widget.onSelected(widget.items[index]);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double distance = (index - _currentIndex).abs().toDouble();
                  if (_pageController.hasClients &&
                      _pageController.page != null) {
                    distance = (index - _pageController.page!).abs();
                  }
                  final scale = (1 - distance * 0.18).clamp(0.78, 1.0);
                  final opacity = (1 - distance * 0.35).clamp(0.42, 1.0);

                  return Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: _CarouselItemCard(item: widget.items[index]),
              );
            },
          ),
          Positioned(
            bottom: 8,
            child: _CarouselPill(
              label: widget.categoryLabel,
              current: _currentIndex + 1,
              total: widget.items.length,
              canGoBack: canGoBack,
              canGoForward: canGoForward,
              onBack: () => _selectPage(_currentIndex - 1),
              onForward: () => _selectPage(_currentIndex + 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselItemCard extends StatelessWidget {
  const _CarouselItemCard({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 48),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: CachedWardrobeImage(item: item, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _CarouselPill extends StatelessWidget {
  const _CarouselPill({
    required this.label,
    required this.current,
    required this.total,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final String label;
  final int current;
  final int total;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillArrow(
            icon: Icons.chevron_left_rounded,
            enabled: canGoBack,
            onTap: onBack,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$label ($current/$total)',
              style: GoogleFonts.spaceMono(
                color: AuthColors.neon,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _PillArrow(
            icon: Icons.chevron_right_rounded,
            enabled: canGoForward,
            onTap: onForward,
          ),
        ],
      ),
    );
  }
}

class _PillArrow extends StatelessWidget {
  const _PillArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        color: enabled ? Colors.white : Colors.white24,
        size: 28,
      ),
    );
  }
}
