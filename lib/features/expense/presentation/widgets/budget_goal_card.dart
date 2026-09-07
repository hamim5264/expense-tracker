import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BudgetGoalCard extends StatelessWidget {
  final BudgetPlan plan;
  final double spent;
  final List<Expense> matchedExpenses;
  final String currencyCode;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetGoalCard({
    super.key,
    required this.plan,
    required this.spent,
    this.matchedExpenses = const [],
    required this.currencyCode,
    required this.isDark,
    required this.primaryColor,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('dining') || cat.contains('restaurant') || cat.contains('grocer') || cat.contains('cafe')) {
      return CupertinoIcons.bag_fill;
    }
    if (cat.contains('transport') || cat.contains('fuel') || cat.contains('car') || cat.contains('taxi') || cat.contains('transit')) {
      return CupertinoIcons.car_detailed;
    }
    if (cat.contains('shopping') || cat.contains('cloth') || cat.contains('store') || cat.contains('tech') || cat.contains('gadget')) {
      return CupertinoIcons.cart_fill;
    }
    if (cat.contains('bill') || cat.contains('utilit') || cat.contains('electric') || cat.contains('water') || cat.contains('recharge')) {
      return CupertinoIcons.bolt_fill;
    }
    if (cat.contains('health') || cat.contains('medic') || cat.contains('doctor') || cat.contains('pharma') || cat.contains('gym') || cat.contains('fit')) {
      return CupertinoIcons.heart_fill;
    }
    if (cat.contains('entertain') || cat.contains('movie') || cat.contains('game') || cat.contains('subscript')) {
      return CupertinoIcons.play_circle_fill;
    }
    if (cat.contains('educat') || cat.contains('school') || cat.contains('book') || cat.contains('course')) {
      return CupertinoIcons.book_fill;
    }
    if (cat.contains('rent') || cat.contains('home') || cat.contains('hous')) {
      return CupertinoIcons.house_fill;
    }
    if (cat.contains('travel') || cat.contains('flight') || cat.contains('hotel')) {
      return CupertinoIcons.airplane;
    }
    return CupertinoIcons.chart_pie_fill;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('grocer') || cat.contains('cafe')) return const Color(0xFFF97316);
    if (cat.contains('transport') || cat.contains('fuel')) return const Color(0xFF0284C7);
    if (cat.contains('shopping') || cat.contains('cloth') || cat.contains('tech')) return const Color(0xFFEC4899);
    if (cat.contains('bill') || cat.contains('utilit') || cat.contains('electric')) return const Color(0xFFEAB308);
    if (cat.contains('health') || cat.contains('pharma') || cat.contains('medic')) return const Color(0xFF10B981);
    if (cat.contains('entertain') || cat.contains('subscript') || cat.contains('game')) return const Color(0xFF8B5CF6);
    if (cat.contains('educat') || cat.contains('school') || cat.contains('course')) return const Color(0xFF3B82F6);
    if (cat.contains('rent') || cat.contains('home') || cat.contains('hous')) return const Color(0xFF92400E);
    if (cat.contains('travel') || cat.contains('flight')) return const Color(0xFF0D9488);
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = plan.targetAmount > 0 ? (spent / plan.targetAmount).clamp(0.0, 1.0) : 0.0;
    final isExceeded = spent > plan.targetAmount;
    final remaining = plan.targetAmount - spent;
    final percent = plan.targetAmount > 0 ? ((spent / plan.targetAmount) * 100) : 0.0;

    final catColor = _getCategoryColor(plan.category);
    final catIcon = _getCategoryIcon(plan.category);

    Color statusColor;
    if (isExceeded) {
      statusColor = const Color(0xFFEF4444);
    } else if (percent >= 85) {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = const Color(0xFF10B981);
    }

    final cardBg = isDark ? const Color(0xFF1A1827) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExceeded
              ? const Color(0xFFEF4444).withOpacity(0.4)
              : borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.16 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Category Icon + Title + Status Pill + Menu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(catIcon, color: catColor, size: 18),
                    ),
                    const SizedBox(width: 12),
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
                            '${plan.category} • ${plan.period == 'monthly' ? 'Monthly' : 'Yearly'}${matchedExpenses.isNotEmpty ? ' • ${matchedExpenses.length} ${matchedExpenses.length == 1 ? 'log' : 'logs'}' : ''}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        CupertinoIcons.ellipsis_vertical,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        size: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: isDark ? const Color(0xFF242236) : Colors.white,
                      onSelected: (action) {
                        if (action == 'edit') {
                          onEdit();
                        } else if (action == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.pencil,
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              const Text('Edit Goal'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.trash, size: 16, color: Color(0xFFEF4444)),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom Spent vs Remaining figures
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyService.format(spent, currencyCode)} spent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isExceeded
                            ? const Color(0xFFEF4444)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExceeded
                              ? 'Over by ${CurrencyService.format(spent - plan.targetAmount, currencyCode)}'
                              : '${CurrencyService.format(remaining, currencyCode)} left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isExceeded
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                        if (matchedExpenses.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 11,
                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
