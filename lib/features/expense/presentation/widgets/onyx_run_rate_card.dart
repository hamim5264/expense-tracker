import 'package:expense_tracker/core/common/utils/onyx_forecast_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnyxRunRateCard extends StatelessWidget {
  final OnyxRunRateForecast forecast;
  final String currencySymbol;
  final bool isDark;
  final Color primaryColor;

  const OnyxRunRateCard({
    super.key,
    required this.forecast,
    required this.currencySymbol,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    final savingsVal = forecast.projectedMonthEndSavings;
    final formattedSavings = savingsVal < 0
        ? '-$currencySymbol${savingsVal.abs().toStringAsFixed(0)}'
        : '$currencySymbol${savingsVal.toStringAsFixed(0)}';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
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
                        CupertinoIcons.graph_circle_fill,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Month-End Run Rate',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: forecast.paceColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: forecast.paceColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  forecast.paceStatus,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: forecast.paceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3 Metric Grid with strictly aligned heights
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _metricColumn(
                    label: 'DAILY BURN',
                    value:
                        '$currencySymbol${forecast.dailyBurnRate.toStringAsFixed(0)}',
                    subtext: '/ day',
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: borderColor,
                ),
                Expanded(
                  child: _metricColumn(
                    label: 'PROJ. SPEND',
                    value:
                        '$currencySymbol${forecast.projectedMonthEndSpend.toStringAsFixed(0)}',
                    subtext: 'month end',
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: borderColor,
                ),
                Expanded(
                  child: _metricColumn(
                    label: 'EST. SAVINGS',
                    value: formattedSavings,
                    subtext:
                        '${forecast.projectedSavingsRate.toStringAsFixed(0)}%',
                    isDark: isDark,
                    valueColor: forecast.projectedMonthEndSavings >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Timeline progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${forecast.daysElapsed} of ${forecast.totalDaysInMonth}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${forecast.daysRemaining} days remaining',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: forecast.monthProgressRatio,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 14),

          // Recommendation text box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: forecast.paceColor.withOpacity(isDark ? 0.08 : 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: forecast.paceColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.lightbulb_fill,
                  size: 15,
                  color: forecast.paceColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    forecast.recommendation,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricColumn({
    required String label,
    required String value,
    required String subtext,
    required bool isDark,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 9.5,
            color: isDark ? Colors.white38 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
