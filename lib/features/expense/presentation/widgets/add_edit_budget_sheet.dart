import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BudgetCategoryOption {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subcategories;

  const BudgetCategoryOption({
    required this.name,
    required this.icon,
    required this.color,
    this.subcategories = const [],
  });
}

class AddEditBudgetSheet extends StatefulWidget {
  final BudgetPlan? existingPlan;
  final String initialPeriodFilter;
  final String currencyCode;
  final bool isDark;
  final Color primaryColor;
  final Function(
    String title,
    double targetAmount,
    String period,
    String category,
  ) onSave;

  const AddEditBudgetSheet({
    super.key,
    this.existingPlan,
    required this.initialPeriodFilter,
    required this.currencyCode,
    required this.isDark,
    required this.primaryColor,
    required this.onSave,
  });

  static const List<BudgetCategoryOption> categoryOptions = [
    BudgetCategoryOption(
      name: 'All',
      icon: CupertinoIcons.chart_pie_fill,
      color: Color(0xFF6366F1),
      subcategories: [],
    ),
    BudgetCategoryOption(
      name: 'Food',
      icon: CupertinoIcons.bag_fill,
      color: Color(0xFFF97316),
      subcategories: ['Groceries', 'Dining Out', 'Cafe & Snacks'],
    ),
    BudgetCategoryOption(
      name: 'Shopping',
      icon: CupertinoIcons.cart_fill,
      color: Color(0xFFEC4899),
      subcategories: ['Clothing', 'Tech & Gadgets', 'Personal Care'],
    ),
    BudgetCategoryOption(
      name: 'Transport',
      icon: CupertinoIcons.car_detailed,
      color: Color(0xFF0284C7),
      subcategories: [
        'Fuel & Gas',
        'Rideshare & Taxi',
        'Public Transit',
        'Vehicle Maintenance',
      ],
    ),
    BudgetCategoryOption(
      name: 'Bills',
      icon: CupertinoIcons.bolt_fill,
      color: Color(0xFFEAB308),
      subcategories: [
        'Utilities',
        'Electricity',
        'Internet & Wi-Fi',
        'Mobile Recharge',
      ],
    ),
    BudgetCategoryOption(
      name: 'Health',
      icon: CupertinoIcons.heart_fill,
      color: Color(0xFF10B981),
      subcategories: ['Medical & Doctor', 'Pharmacy', 'Fitness & Gym'],
    ),
    BudgetCategoryOption(
      name: 'Entertainment',
      icon: CupertinoIcons.play_circle_fill,
      color: Color(0xFF8B5CF6),
      subcategories: ['Subscriptions', 'Movies & Streaming', 'Gaming'],
    ),
    BudgetCategoryOption(
      name: 'Rent/Home',
      icon: CupertinoIcons.house_fill,
      color: Color(0xFF92400E),
      subcategories: ['Rent & Housing', 'Home Maintenance', 'Pets'],
    ),
    BudgetCategoryOption(
      name: 'Education',
      icon: CupertinoIcons.book_fill,
      color: Color(0xFF3B82F6),
      subcategories: ['Tuition & School', 'Online Courses', 'Books'],
    ),
    BudgetCategoryOption(
      name: 'Family & Kids',
      icon: CupertinoIcons.person_2_fill,
      color: Color(0xFFF43F5E),
      subcategories: ['Childcare', 'Gifts & Charity'],
    ),
    BudgetCategoryOption(
      name: 'Travel',
      icon: CupertinoIcons.airplane,
      color: Color(0xFF0D9488),
      subcategories: ['Flights', 'Hotels & Stay', 'Vacation'],
    ),
    BudgetCategoryOption(
      name: 'Others',
      icon: CupertinoIcons.ellipsis_circle_fill,
      color: Color(0xFF64748B),
      subcategories: ['Services', 'Taxes & Fees'],
    ),
  ];

  @override
  State<AddEditBudgetSheet> createState() => _AddEditBudgetSheetState();
}

class _AddEditBudgetSheetState extends State<AddEditBudgetSheet> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _period;
  late String _category;
  String? _subcategory;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingPlan?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existingPlan != null
          ? widget.existingPlan!.targetAmount.toStringAsFixed(0)
          : '',
    );
    _period = widget.existingPlan?.period ?? widget.initialPeriodFilter;
    _category = widget.existingPlan?.category ?? 'All';

    // Check if initial category is a subcategory
    for (final cat in AddEditBudgetSheet.categoryOptions) {
      if (cat.subcategories.contains(_category)) {
        _subcategory = _category;
        _category = cat.name;
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  BudgetCategoryOption _getActiveCategory() {
    return AddEditBudgetSheet.categoryOptions.firstWhere(
      (c) => c.name.toLowerCase() == _category.toLowerCase(),
      orElse: () => AddEditBudgetSheet.categoryOptions.first,
    );
  }

  void _openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            final isDark = widget.isDark;
            final sheetBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
            final borderColor = isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade200;

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Category or Subcategory',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill,
                              size: 20),
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: borderColor, height: 1),

                  // Category & Subcategory List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: AddEditBudgetSheet.categoryOptions.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final cat = AddEditBudgetSheet.categoryOptions[idx];
                        final isSelected = _category == cat.name;

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cat.color.withOpacity(isDark ? 0.14 : 0.08)
                                : (isDark
                                    ? Colors.white.withOpacity(0.03)
                                    : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? cat.color.withOpacity(0.5)
                                  : borderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Category Row
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    _category = cat.name;
                                    _subcategory = null;
                                    if (_nameController.text.trim().isEmpty ||
                                        _nameController.text.endsWith('Budget') ||
                                        _nameController.text.endsWith('Limit')) {
                                      _nameController.text = cat.name == 'All'
                                          ? 'Overall Budget'
                                          : '${cat.name} Budget';
                                    }
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 11),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: cat.color.withOpacity(0.16),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(cat.icon,
                                            size: 16, color: cat.color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          cat.name == 'All'
                                              ? 'All Categories (Entire Budget Pool)'
                                              : cat.name,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected && _subcategory == null)
                                        Icon(CupertinoIcons.checkmark_alt_circle_fill,
                                            size: 18, color: cat.color),
                                    ],
                                  ),
                                ),
                              ),

                              // Subcategories Chip Wrap
                              if (cat.subcategories.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: cat.subcategories.map((sub) {
                                      final isSubSelected =
                                          _category == cat.name &&
                                              _subcategory == sub;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _category = cat.name;
                                            _subcategory = sub;
                                            if (_nameController.text
                                                    .trim()
                                                    .isEmpty ||
                                                _nameController.text
                                                    .endsWith('Budget') ||
                                                _nameController.text
                                                    .endsWith('Limit')) {
                                              _nameController.text =
                                                  '$sub Limit';
                                            }
                                          });
                                          Navigator.pop(ctx);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9, vertical: 4.5),
                                          decoration: BoxDecoration(
                                            color: isSubSelected
                                                ? cat.color
                                                : (isDark
                                                    ? Colors.white
                                                        .withOpacity(0.06)
                                                    : Colors.grey.shade200),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            sub,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isSubSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSubSelected
                                                  ? Colors.white
                                                  : (isDark
                                                      ? Colors.white70
                                                      : Colors.black87),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.grey.shade300;
    final systemBottom = MediaQuery.of(context).viewPadding.bottom;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = keyboardBottom > 0
        ? keyboardBottom + 16
        : (systemBottom > 0 ? systemBottom + 28 : 42.0);

    final activeCat = _getActiveCategory();
    final displayName = _subcategory ??
        (activeCat.name == 'All' ? 'All Categories (Pool)' : activeCat.name);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1B29) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Header: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingPlan != null
                      ? 'Edit Budget Target'
                      : 'New Budget Target',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: widget.isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Transparent Monetary Target Amount Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Text(
                    widget.currencyCode,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: widget.isDark
                              ? Colors.white24
                              : Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Text(
                    'LIMIT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: widget.isDark ? Colors.white30 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Transparent Budget Title Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _nameController,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Plan title (e.g. Monthly Food & Grocery Cap)',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: widget.isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Compact Period Selector & Category Selector Row
            Row(
              children: [
                // Period Toggle (Monthly vs Yearly)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _period = 'monthly'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: _period == 'monthly'
                                    ? widget.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Monthly',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                  color: _period == 'monthly'
                                      ? Colors.white
                                      : (widget.isDark
                                          ? Colors.white60
                                          : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _period = 'yearly'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: _period == 'yearly'
                                    ? widget.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Yearly',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                  color: _period == 'yearly'
                                      ? Colors.white
                                      : (widget.isDark
                                          ? Colors.white60
                                          : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Category Selector Tile (Replaces DropdownButtonFormField!)
                Expanded(
                  flex: 6,
                  child: GestureDetector(
                    onTap: _openCategoryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: activeCat.color.withOpacity(widget.isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeCat.color.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(activeCat.icon,
                              size: 15, color: activeCat.color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_up_chevron_down,
                            size: 13,
                            color: activeCat.color,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  final title = _nameController.text.trim();
                  final target =
                      double.tryParse(_amountController.text.trim()) ?? 0.0;
                  final categoryToSave = _subcategory ?? _category;
                  widget.onSave(title, target, _period, categoryToSave);
                },
                child: Text(
                  widget.existingPlan != null
                      ? 'Update Target'
                      : 'Save Budget Plan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
