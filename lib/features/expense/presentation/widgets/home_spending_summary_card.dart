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

    final todayTransactions = allExpenses.where((e) {
      final d = e.date.toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final todayExpense = todayTransactions
        .where((e) => e.type == 'expense')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final todayIncome = todayTransactions
        .where((e) => e.type == 'income')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final monthTransactions = allExpenses.where((e) {
      final d = e.date.toLocal();
      return d.year == now.year && d.month == now.month;
    }).toList();

    final monthExpense = monthTransactions
        .where((e) => e.type == 'expense')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final monthIncome = monthTransactions
        .where((e) => e.type == 'income')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final bool hasTodayExpense = todayExpense > 0;
    final bool hasTodayIncome = todayIncome > 0;

    String todayDisplayText;
    Color todayTextColor;
    double todayRingValue;
    Color todayRingColor;
    String todayLabel = 'Today';

    if (hasTodayExpense && hasTodayIncome) {
      todayDisplayText = CurrencyService.format(todayExpense, currencyCode);
      todayTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
      todayRingValue = monthExpense > 0
          ? (todayExpense / monthExpense).clamp(0.05, 1.0)
          : 0.5;
      todayRingColor = const Color(0xFF10B981);
    } else if (hasTodayExpense) {
      todayDisplayText = CurrencyService.format(todayExpense, currencyCode);
      todayTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
      todayRingValue = monthExpense > 0
          ? (todayExpense / monthExpense).clamp(0.05, 1.0)
          : 0.5;
      todayRingColor = const Color(0xFF10B981);
    } else if (hasTodayIncome) {
      todayDisplayText = '+ ${CurrencyService.format(todayIncome, currencyCode)}';
      todayTextColor = const Color(0xFF10B981);
      todayRingValue = 1.0;
      todayRingColor = const Color(0xFF10B981);
      todayLabel = 'Today (Income)';
    } else {
      todayDisplayText = CurrencyService.format(0.0, currencyCode);
      todayTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
      todayRingValue = 0.0;
      todayRingColor = const Color(0xFF10B981);
    }

    final String monthDisplayText = monthExpense > 0
        ? CurrencyService.format(monthExpense, currencyCode)
        : (monthIncome > 0
            ? '+ ${CurrencyService.format(monthIncome, currencyCode)}'
            : CurrencyService.format(0.0, currencyCode));
    final Color monthTextColor = (monthExpense == 0 && monthIncome > 0)
        ? const Color(0xFF10B981)
        : (isDark ? Colors.white : const Color(0xFF0F172A));

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
          // Today's Spending / Activity
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    value: todayRingValue,
                    strokeWidth: 4,
                    backgroundColor: isDark
                        ? const Color(0xFF2A2640)
                        : const Color(0xFFE2E8F0),
                    color: todayRingColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        todayLabel,
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
                          todayDisplayText,
                          style: TextStyle(
                            color: todayTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hasTodayExpense && hasTodayIncome) ...[
                        const SizedBox(height: 1),
                        Text(
                          '+${CurrencyService.format(todayIncome, currencyCode)} in',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

          // Current Month's Total
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    value: monthExpense <= 0 ? (monthIncome > 0 ? 1.0 : 0.0) : 0.75,
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
                          monthDisplayText,
                          style: TextStyle(
                            color: monthTextColor,
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
