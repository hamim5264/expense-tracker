import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:flutter/material.dart';

class HomeSpendingSummaryCard extends StatelessWidget {
  final List<Expense> allExpenses;
  final String currencyCode;
  final bool isDark;

  const HomeSpendingSummaryCard({
    super.key,
    required this.allExpenses,
    required this.currencyCode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final todayTotal = allExpenses.where((e) {
      return e.type == 'expense' &&
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day;
    }).fold<double>(0.0, (sum, e) => sum + e.amount);

    final monthTotal = allExpenses.where((e) {
      return e.type == 'expense' &&
          e.date.year == now.year &&
          e.date.month == now.month;
    }).fold<double>(0.0, (sum, e) => sum + e.amount);

    final monthName = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][now.month - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Today's Spending
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    value: todayTotal <= 0
                        ? 0.0
                        : (monthTotal > 0
                            ? (todayTotal / monthTotal).clamp(0.05, 1.0)
                            : 0.0),
                    strokeWidth: 4,
                    backgroundColor: isDark
                        ? const Color(0xFF2A2640)
                        : const Color(0xFFE2E8F0),
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Today',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyService.format(todayTotal, currencyCode),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider Line
          Container(
            height: 36,
            width: 1,
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.black.withOpacity(0.1),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // Current Month's Total Spending
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    value: monthTotal <= 0 ? 0.0 : 0.75,
                    strokeWidth: 4,
                    backgroundColor: isDark
                        ? const Color(0xFF2A2640)
                        : const Color(0xFFE2E8F0),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthName,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyService.format(monthTotal, currencyCode),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
