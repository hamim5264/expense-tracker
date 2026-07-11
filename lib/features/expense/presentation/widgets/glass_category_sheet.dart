import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCategorySheet extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.fastfood_rounded, 'color': Colors.orange},
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': Colors.purple,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie_creation_rounded,
      'color': Colors.pink,
    },
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded, 'color': Colors.blue},
    {
      'name': 'Travel',
      'icon': Icons.directions_car_rounded,
      'color': Colors.teal,
    },
    {
      'name': 'Salary',
      'icon': Icons.monetization_on_rounded,
      'color': Colors.green,
    },
    {'name': 'Education', 'icon': Icons.school_rounded, 'color': Colors.indigo},
    {
      'name': 'Health',
      'icon': Icons.medical_services_rounded,
      'color': Colors.red,
    },
    {
      'name': 'Investment',
      'icon': Icons.trending_up_rounded,
      'color': Colors.amber,
    },
    {
      'name': 'Groceries',
      'icon': Icons.local_grocery_store_rounded,
      'color': Colors.lightGreen,
    },
    {'name': 'Insurance', 'icon': Icons.security_rounded, 'color': Colors.cyan},
    {
      'name': 'Gift/Donation',
      'icon': Icons.card_giftcard_rounded,
      'color': Colors.deepOrange,
    },
    {'name': 'Rent/Home', 'icon': Icons.home_rounded, 'color': Colors.brown},
    {
      'name': 'Others',
      'icon': Icons.miscellaneous_services_rounded,
      'color': Colors.grey,
    },
  ];

  const GlassCategorySheet({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withAlpha(200)
        : Colors.white.withAlpha(225);
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(20);
    final textColor = isDark ? Colors.white : Colors.black87;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: glassBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat['name'];
                  final Color catColor = cat['color'] as Color;

                  return GestureDetector(
                    onTap: () {
                      onCategorySelected(cat['name'] as String);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor.withAlpha(40)
                            : (isDark ? Colors.white10 : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? catColor
                              : Colors.grey.withAlpha(40),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: catColor.withAlpha(25),
                            radius: 22,
                            child: Icon(
                              cat['icon'] as IconData,
                              color: catColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
