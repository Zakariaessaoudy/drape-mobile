import 'package:flutter/material.dart';

class DrapeBottomNav extends StatelessWidget {
  const DrapeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItemData> _items = <_NavItemData>[
    _NavItemData(label: 'WARDROBE', icon: Icons.checkroom),
    _NavItemData(label: 'TRY-ON', icon: Icons.auto_awesome),
    _NavItemData(label: 'FEED', icon: Icons.local_fire_department),
    _NavItemData(label: 'PROFILE', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Color(0xFF222222)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    isActive
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6F135),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              color: const Color(0xFF111111),
                            ),
                          )
                        : Icon(item.icon, color: const Color(0xFF888888)),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFFC6F135)
                            : const Color(0xFF888888),
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
