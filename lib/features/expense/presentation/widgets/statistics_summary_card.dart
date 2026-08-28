import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';

class StatisticsSummaryCard extends StatelessWidget {
  final String selectedType;
  final double totalIncome;
  final double totalExpenses;
  final String currencyCode;
  final bool isDark;
  final ValueChanged<String> onTypeChanged;

  const StatisticsSummaryCard({
    super.key,
    required this.selectedType,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currencyCode,
    required this.isDark,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = selectedType == 'income' ? totalIncome : totalExpenses;
    final net = totalIncome - totalExpenses;
    final isPositive = net >= 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(35) : Colors.white.withAlpha(220),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withAlpha(60) : Colors.black.withAlpha(15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Income Selector Box
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTypeChanged('income'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedType == 'income'
                              ? const Color(0xFF22C55E).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedType == 'income'
                                ? const Color(0xFF22C55E).withOpacity(0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                    fontWeight: selectedType == 'income'
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyService.format(totalIncome, currencyCode),
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  // Expenses Selector Box
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTypeChanged('expense'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedType == 'expense'
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedType == 'expense'
                                ? const Color(0xFFEF4444).withOpacity(0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Expenses',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                    fontWeight: selectedType == 'expense'
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyService.format(totalExpenses, currencyCode),
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: isDark ? Colors.white24 : Colors.grey.shade200,
                height: 1,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total ${selectedType == 'expense' ? 'Spendings' : 'Earnings'}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyService.format(totalAmount, currencyCode),
                            style: TextStyle(
                              color: selectedType == 'income'
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: const BoxConstraints(maxWidth: 150),
                    decoration: BoxDecoration(
                      color: (isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                            .withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Net Balance',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            CurrencyService.format(net, currencyCode),
                            style: TextStyle(
                              color: isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
