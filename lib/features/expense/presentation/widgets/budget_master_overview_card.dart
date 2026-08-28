import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:flutter/material.dart';

class BudgetMasterOverviewCard extends StatelessWidget {
  final String currencyCode;
  final double totalTarget;
  final double totalSpent;
  final String selectedPeriodFilter;
  final bool isDark;
  final Color primaryColor;

  const BudgetMasterOverviewCard({
    super.key,
    required this.currencyCode,
    required this.totalTarget,
    required this.totalSpent,
    required this.selectedPeriodFilter,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalTarget > 0 ? (totalSpent / totalTarget).clamp(0.0, 1.0) : 0.0;
    final remaining = totalTarget - totalSpent;
    final isExceeded = totalSpent > totalTarget && totalTarget > 0;

    final badgeColor = isExceeded
        ? const Color(0xFFFF5252)
        : (isDark ? const Color(0xFF60A5FA) : primaryColor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B29) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall ${selectedPeriodFilter == 'monthly' ? 'Monthly' : 'Yearly'} Budget',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyService.format(totalSpent, currencyCode),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isExceeded ? const Color(0xFFFF5252) : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(percent * 100).toStringAsFixed(1)}% Spent',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExceeded
                    ? const Color(0xFFFF5252)
                    : (percent > 0.85 ? Colors.orange : (isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E))),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Target: ${CurrencyService.format(totalTarget, currencyCode)}',
                style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : Colors.grey.shade600),
              ),
              Text(
                isExceeded
                    ? 'Over by ${CurrencyService.format(totalSpent - totalTarget, currencyCode)}'
                    : 'Remaining: ${CurrencyService.format(remaining, currencyCode)}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isExceeded ? const Color(0xFFFF5252) : (isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
