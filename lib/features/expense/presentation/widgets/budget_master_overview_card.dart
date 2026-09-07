import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:flutter/cupertino.dart';
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

    final now = DateTime.now();
    final isMonthly = selectedPeriodFilter == 'monthly';
    final totalDaysInPeriod = isMonthly
        ? DateTime(now.year, now.month + 1, 0).day
        : (DateTime(now.year + 1, 1, 1).difference(DateTime(now.year, 1, 1)).inDays);
    final daysElapsed = isMonthly
        ? now.day
        : now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    final daysRemaining = (totalDaysInPeriod - daysElapsed).clamp(1, totalDaysInPeriod);
    final dailySafeRunRate = remaining > 0 ? (remaining / daysRemaining) : 0.0;

    Color statusColor;
    String statusText;
    if (totalTarget <= 0) {
      statusColor = isDark ? Colors.white38 : Colors.grey.shade500;
      statusText = 'No Target Set';
    } else if (isExceeded) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'Over by ${CurrencyService.format(totalSpent - totalTarget, currencyCode)}';
    } else if (percent >= 0.85) {
      statusColor = const Color(0xFFF59E0B);
      statusText = '${(percent * 100).toStringAsFixed(0)}% Used';
    } else {
      statusColor = const Color(0xFF10B981);
      statusText = 'Healthy • ${(percent * 100).toStringAsFixed(0)}% Used';
    }

    final cardBg = isDark ? const Color(0xFF1A1827) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.chart_pie_fill,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${selectedPeriodFilter == 'monthly' ? 'Monthly' : 'Yearly'} Budget Pool',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                  statusText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Two Primary Figures: Total Spent vs Safe Buffer
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SPENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyService.format(totalSpent, currencyCode),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isExceeded
                            ? const Color(0xFFEF4444)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalTarget <= 0
                          ? 'TARGET LIMIT'
                          : (isExceeded ? 'DEFICIT AMOUNT' : 'SAFE BUFFER LEFT'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalTarget <= 0
                          ? 'Not Set'
                          : CurrencyService.format(remaining.abs(), currencyCode),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: totalTarget <= 0
                            ? (isDark ? Colors.white38 : Colors.grey.shade400)
                            : (isExceeded
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Bar with rounded track
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExceeded
                    ? const Color(0xFFEF4444)
                    : (percent >= 0.85
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Bottom Metric Row (Target limit & Daily safe run rate)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Target: ${totalTarget > 0 ? CurrencyService.format(totalTarget, currencyCode) : '৳0.00'}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    totalTarget > 0 && remaining > 0
                        ? '${CurrencyService.format(dailySafeRunRate, currencyCode)}/day'
                        : '$daysRemaining days left',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
