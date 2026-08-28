import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:flutter/material.dart';

class AddEditBudgetSheet extends StatefulWidget {
  final BudgetPlan? existingPlan;
  final String initialPeriodFilter;
  final String currencyCode;
  final bool isDark;
  final Color primaryColor;
  final Function(String title, double targetAmount, String period, String category) onSave;

  const AddEditBudgetSheet({
    super.key,
    this.existingPlan,
    required this.initialPeriodFilter,
    required this.currencyCode,
    required this.isDark,
    required this.primaryColor,
    required this.onSave,
  });

  @override
  State<AddEditBudgetSheet> createState() => _AddEditBudgetSheetState();
}

class _AddEditBudgetSheetState extends State<AddEditBudgetSheet> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _period;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingPlan?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existingPlan != null ? widget.existingPlan!.targetAmount.toStringAsFixed(2) : '',
    );
    _period = widget.existingPlan?.period ?? widget.initialPeriodFilter;
    _category = widget.existingPlan?.category ?? 'All';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 28;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
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
            const SizedBox(height: 12),
            Text(
              widget.existingPlan != null ? 'Edit Budget Target' : 'Create New Budget Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Budget Name
            Text(
              'BUDGET TITLE',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: widget.isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                hintText: 'e.g. Monthly Grocery & Food Limit',
                hintStyle: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white30 : Colors.grey.shade400),
                fillColor: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Target Amount
            Text(
              'TARGET LIMIT AMOUNT',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: widget.isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: widget.isDark ? Colors.white : widget.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                prefixText: '${widget.currencyCode} ',
                prefixStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white70 : widget.primaryColor,
                ),
                hintText: '500.00',
                hintStyle: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white30 : Colors.grey.shade400),
                fillColor: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Period Selector (Monthly vs Yearly)
            Text(
              'PLAN PERIOD',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: widget.isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _period = 'monthly'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _period == 'monthly'
                            ? widget.primaryColor
                            : (widget.isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Monthly Plan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: _period == 'monthly' ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _period = 'yearly'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _period == 'yearly'
                            ? widget.primaryColor
                            : (widget.isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Yearly Plan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: _period == 'yearly' ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Category Selector
            Text(
              'APPLY TO CATEGORY',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: widget.isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor: widget.isDark ? const Color(0xFF1E1B29) : Colors.white,
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                fillColor: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
              items: ['All', 'Food', 'Shopping', 'Entertainment', 'Health', 'Transport', 'Utilities', 'Salary', 'Others']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val ?? 'All'),
            ),
            const SizedBox(height: 18),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final title = _nameController.text.trim();
                  final target = double.tryParse(_amountController.text.trim()) ?? 0.0;
                  widget.onSave(title, target, _period, _category);
                },
                child: const Text(
                  'Save Budget Plan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
