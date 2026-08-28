import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';

class BudgetGoalCard extends StatelessWidget {
  final BudgetPlan plan;
  final double spent;
  final String currencyCode;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetGoalCard({
    super.key,
    required this.plan,
    required this.spent,
    required this.currencyCode,
    required this.isDark,
    required this.primaryColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (spent / plan.targetAmount).clamp(0.0, 1.0);
    final isExceeded = spent > plan.targetAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B29) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExceeded
              ? const Color(0xFFFF5252).withOpacity(0.5)
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Category: ${plan.category}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                  size: 18,
                ),
                onSelected: (action) {
                  if (action == 'edit') {
                    onEdit();
                  } else if (action == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Progress Bar Color: Green (< 70%) -> Yellow (70% - 90%) -> Red (> 90% / Exceeded)
          Builder(builder: (context) {
            Color progressColor;
            if (isExceeded || ratio >= 0.90) {
              progressColor = const Color(0xFFEF4444); // Vibrant Red
            } else if (ratio >= 0.70) {
              progressColor = const Color(0xFFEAB308); // Warm Yellow/Amber
            } else {
              progressColor = const Color(0xFF22C55E); // Crisp Green
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            );
          }),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyService.format(spent, currencyCode)} spent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isExceeded
                      ? const Color(0xFFFF5252)
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              Text(
                'Target: ${CurrencyService.format(plan.targetAmount, currencyCode)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
