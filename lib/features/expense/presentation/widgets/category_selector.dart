import 'package:expense_tracker/features/expense/presentation/widgets/glass_category_sheet.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final catInfo = GlassCategorySheet.categories.firstWhere(
      (c) => c['name'] == selectedCategory,
      orElse: () => {
        'name': selectedCategory,
        'icon': Icons.miscellaneous_services_rounded,
        'color': Colors.grey,
      },
    );

    final Color catColor = catInfo['color'] as Color;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          barrierColor: Colors.black.withAlpha(80),
          builder: (sheetContext) => GlassCategorySheet(
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: catColor.withAlpha(80), width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: catColor.withAlpha(25),
              radius: 20,
              child: Icon(
                catInfo['icon'] as IconData,
                color: catColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategory,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to change category',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
