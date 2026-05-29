import 'package:flutter/material.dart';

class FilterRow extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  static const List<_FilterOption> _filters = <_FilterOption>[
    _FilterOption(label: 'ALL', value: 'ALL'),
    _FilterOption(label: 'TOPS', value: 'TOP'),
    _FilterOption(label: 'BOTTOMS', value: 'BOTTOM'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => Container(
          width: 1,
          margin: const EdgeInsets.symmetric(vertical: 12),
          color: const Color(0xFF444444),
        ),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = selectedFilter == filter.value;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onFilterSelected(filter.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isActive) ...<Widget>[
                    const Icon(Icons.check, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    filter.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption({required this.label, required this.value});

  final String label;
  final String value;
}
