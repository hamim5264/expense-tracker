import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportsFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const ReportsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<Map<String, dynamic>> filterItems = [
    {
      'label': 'All',
      'icon': CupertinoIcons.doc_text,
    },
    {
      'label': 'Expense',
      'icon': CupertinoIcons.arrow_down_to_line,
    },
    {
      'label': 'Income',
      'icon': CupertinoIcons.arrow_up_to_line,
    },
    {
      'label': 'Custom',
      'icon': CupertinoIcons.calendar,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryPurple = Color(0xFF563294);
    final unselectedBg = isDark ? const Color(0xFF221E33) : const Color(0xFFF0EAF9);
    final unselectedText = isDark ? const Color(0xFFD4CCE6) : const Color(0xFF211B38);

    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        itemCount: filterItems.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = filterItems[index];
          final String label = item['label'] as String;
          final IconData icon = item['icon'] as IconData;
          final bool isSelected = selectedFilter == label;

          return GestureDetector(
            onTap: () => onFilterSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primaryPurple : unselectedBg,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: isSelected ? Colors.white : primaryPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : unselectedText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
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
