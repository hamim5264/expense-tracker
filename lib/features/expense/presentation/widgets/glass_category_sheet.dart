import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCategorySheet extends StatefulWidget {
  final String selectedCategory;
  final String transactionType;
  final ValueChanged<String> onCategorySelected;

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Food',
      'icon': Icons.fastfood_rounded,
      'color': Colors.orange,
      'type': 'expense',
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': Colors.purple,
      'type': 'expense',
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie_creation_rounded,
      'color': Colors.pink,
      'type': 'expense',
    },
    {
      'name': 'Bills',
      'icon': Icons.receipt_long_rounded,
      'color': Colors.blue,
      'type': 'expense',
    },
    {
      'name': 'Travel',
      'icon': Icons.directions_car_rounded,
      'color': Colors.teal,
      'type': 'expense',
    },
    {
      'name': 'Education',
      'icon': Icons.school_rounded,
      'color': Colors.indigo,
      'type': 'expense',
    },
    {
      'name': 'Health',
      'icon': Icons.medical_services_rounded,
      'color': Colors.red,
      'type': 'expense',
    },
    {
      'name': 'Groceries',
      'icon': Icons.local_grocery_store_rounded,
      'color': Colors.lightGreen,
      'type': 'expense',
    },
    {
      'name': 'Insurance',
      'icon': Icons.security_rounded,
      'color': Colors.cyan,
      'type': 'expense',
    },
    {
      'name': 'Rent/Home',
      'icon': Icons.home_rounded,
      'color': Colors.brown,
      'type': 'expense',
    },
    {
      'name': 'Subscriptions',
      'icon': Icons.subscriptions_rounded,
      'color': Colors.amber,
      'type': 'expense',
    },
    {
      'name': 'Transport',
      'icon': Icons.train_rounded,
      'color': Colors.blueGrey,
      'type': 'expense',
    },
    {
      'name': 'Utilities',
      'icon': Icons.bolt_rounded,
      'color': Colors.orangeAccent,
      'type': 'expense',
    },
    {
      'name': 'Services',
      'icon': Icons.construction_rounded,
      'color': Colors.grey,
      'type': 'expense',
    },
    {
      'name': 'Dining Out',
      'icon': Icons.restaurant_rounded,
      'color': Colors.deepOrangeAccent,
      'type': 'expense',
    },
    {
      'name': 'Family',
      'icon': Icons.people_rounded,
      'color': Colors.indigoAccent,
      'type': 'expense',
    },
    {
      'name': 'Maintenance',
      'icon': Icons.home_repair_service_rounded,
      'color': Colors.brown,
      'type': 'expense',
    },

    {
      'name': 'Salary',
      'icon': Icons.monetization_on_rounded,
      'color': Colors.green,
      'type': 'income',
    },
    {
      'name': 'Freelance',
      'icon': Icons.work_rounded,
      'color': Colors.greenAccent,
      'type': 'income',
    },
    {
      'name': 'Investment',
      'icon': Icons.trending_up_rounded,
      'color': Colors.amber,
      'type': 'income',
    },
    {
      'name': 'Bonus',
      'icon': Icons.card_membership_rounded,
      'color': Colors.purpleAccent,
      'type': 'income',
    },
    {
      'name': 'Dividend',
      'icon': Icons.pie_chart_rounded,
      'color': Colors.cyanAccent,
      'type': 'income',
    },
    {
      'name': 'Gift/Donation',
      'icon': Icons.card_giftcard_rounded,
      'color': Colors.deepOrange,
      'type': 'income',
    },
    {
      'name': 'Refund',
      'icon': Icons.restore_rounded,
      'color': Colors.lightBlueAccent,
      'type': 'income',
    },
    {
      'name': 'Others',
      'icon': Icons.miscellaneous_services_rounded,
      'color': Colors.grey,
      'type': 'income',
    },
  ];

  const GlassCategorySheet({
    super.key,
    required this.selectedCategory,
    required this.transactionType,
    required this.onCategorySelected,
  });

  @override
  State<GlassCategorySheet> createState() => _GlassCategorySheetState();
}

class _GlassCategorySheetState extends State<GlassCategorySheet> {
  late String _activeTypeFilter;

  @override
  void initState() {
    super.initState();
    _activeTypeFilter = widget.transactionType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withOpacity(0.8)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final textColor = isDark ? Colors.white : Colors.black87;

    final filteredList = GlassCategorySheet.categories
        .where((cat) => cat['type'] == _activeTypeFilter)
        .toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
            const SizedBox(height: 16),
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _activeTypeFilter = 'expense'),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _activeTypeFilter == 'expense'
                                ? theme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Expense Categories',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeTypeFilter == 'expense'
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white60
                                        : Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _activeTypeFilter = 'income'),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _activeTypeFilter == 'income'
                                ? theme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Income Categories',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeTypeFilter == 'income'
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white60
                                        : Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final cat = filteredList[index];
                  final isSelected = widget.selectedCategory == cat['name'];
                  final Color catColor = cat['color'] as Color;

                  return GestureDetector(
                    onTap: () {
                      widget.onCategorySelected(cat['name'] as String);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor.withOpacity(0.12)
                            : (isDark ? Colors.white10 : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? catColor
                              : Colors.grey.withOpacity(0.15),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: catColor.withOpacity(0.1),
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
