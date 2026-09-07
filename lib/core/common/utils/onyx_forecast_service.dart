import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:flutter/material.dart';

class OnyxRunRateForecast {
  final int daysElapsed;
  final int daysRemaining;
  final int totalDaysInMonth;
  final double currentMonthSpend;
  final double currentMonthIncome;
  final double dailyBurnRate;
  final double projectedMonthEndSpend;
  final double projectedMonthEndSavings;
  final double projectedSavingsRate;
  final String paceStatus;
  final Color paceColor;
  final String recommendation;

  OnyxRunRateForecast({
    required this.daysElapsed,
    required this.daysRemaining,
    required this.totalDaysInMonth,
    required this.currentMonthSpend,
    required this.currentMonthIncome,
    required this.dailyBurnRate,
    required this.projectedMonthEndSpend,
    required this.projectedMonthEndSavings,
    required this.projectedSavingsRate,
    required this.paceStatus,
    required this.paceColor,
    required this.recommendation,
  });

  double get monthProgressRatio =>
      (daysElapsed / totalDaysInMonth).clamp(0.0, 1.0);
}

class OnyxForecastService {
  static OnyxRunRateForecast calculate(List<Expense> expenses) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final totalDaysInMonth = lastDayOfMonth.day;
    final daysElapsed = now.day;
    final daysRemaining = (totalDaysInMonth - daysElapsed).clamp(0, 31);

    // Current month transactions
    final currentMonthExpenses = expenses.where((e) {
      return e.type == 'expense' &&
          e.date.isAfter(firstDayOfMonth.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).fold(0.0, (sum, item) => sum + item.amount);

    final currentMonthIncome = expenses.where((e) {
      return e.type == 'income' &&
          e.date.isAfter(firstDayOfMonth.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).fold(0.0, (sum, item) => sum + item.amount);

    final safeDaysElapsed = daysElapsed > 0 ? daysElapsed : 1;
    final dailyBurnRate = currentMonthExpenses / safeDaysElapsed;

    final projectedAdditionalSpend = dailyBurnRate * daysRemaining;
    final projectedMonthEndSpend = currentMonthExpenses + projectedAdditionalSpend;
    final projectedMonthEndSavings = currentMonthIncome - projectedMonthEndSpend;

    double projectedSavingsRate = 0.0;
    if (currentMonthIncome > 0) {
      projectedSavingsRate =
          (projectedMonthEndSavings / currentMonthIncome) * 100;
    }

    String paceStatus;
    Color paceColor;
    String recommendation;

    if (currentMonthIncome > 0) {
      final spendRatio = (projectedMonthEndSpend / currentMonthIncome);
      if (spendRatio < 0.70) {
        paceStatus = 'Under Budget';
        paceColor = const Color(0xFF10B981);
        recommendation =
            'Excellent burn rate! You are pacing to save ${projectedSavingsRate.toStringAsFixed(0)}% of your monthly earnings.';
      } else if (spendRatio <= 0.90) {
        paceStatus = 'On Track';
        paceColor = const Color(0xFF3B82F6);
        recommendation =
            'Healthy burn rate. You are on track to close the month with a surplus.';
      } else if (spendRatio <= 1.0) {
        paceStatus = 'Pacing Fast';
        paceColor = const Color(0xFFF59E0B);
        recommendation =
            'Warning: Spending is accelerating. Tighten discretionary categories to avoid deficit.';
      } else {
        paceStatus = 'Deficit Risk';
        paceColor = const Color(0xFFEF4444);
        recommendation =
            'At this rate, you will exceed your income by ${(projectedMonthEndSpend - currentMonthIncome).toStringAsFixed(0)}. Slow down spending immediately.';
      }
    } else {
      if (currentMonthExpenses == 0) {
        paceStatus = 'Fresh Period';
        paceColor = const Color(0xFF6B7280);
        recommendation =
            'Start recording your daily expenses and income to see live month-end run-rate projections.';
      } else {
        paceStatus = 'Pacing Ahead';
        paceColor = const Color(0xFFF59E0B);
        recommendation =
            'Recording your monthly income will unlock deep surplus and deficit forecasting.';
      }
    }

    return OnyxRunRateForecast(
      daysElapsed: daysElapsed,
      daysRemaining: daysRemaining,
      totalDaysInMonth: totalDaysInMonth,
      currentMonthSpend: currentMonthExpenses,
      currentMonthIncome: currentMonthIncome,
      dailyBurnRate: dailyBurnRate,
      projectedMonthEndSpend: projectedMonthEndSpend,
      projectedMonthEndSavings: projectedMonthEndSavings,
      projectedSavingsRate: projectedSavingsRate,
      paceStatus: paceStatus,
      paceColor: paceColor,
      recommendation: recommendation,
    );
  }
}
