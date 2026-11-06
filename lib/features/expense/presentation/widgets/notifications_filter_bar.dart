import 'package:flutter/material.dart';

class FilterItem {
  final String label;
  final IconData? icon;

  const FilterItem(this.label, [this.icon]);
}

class NotificationsFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final bool isDark;

  const NotificationsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.isDark,
  });

  static const List<FilterItem> filters = [
    FilterItem('All'),
    FilterItem('Updates', Icons.system_update_alt_rounded),
    FilterItem('Announcements', Icons.campaign_outlined),
    FilterItem('Features', Icons.layers_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF563794);

    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final isSelected = selectedFilter == item.label;

          return GestureDetector(
            onTap: () => onFilterSelected(item.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF1E1B29) : Colors.white),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white12 : const Color(0xFFEFE8FB)),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 15,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF77728E)),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF201B38)),
                    ),
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
