import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:flutter/material.dart';

class HealthPillar {
  final String name;
  final double score;
  final double maxScore;
  final String tip;
  final Color color;

  HealthPillar({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.tip,
    required this.color,
  });

  double get ratio => (score / maxScore).clamp(0.0, 1.0);
  int get percentage => (ratio * 100).round();
}

class OnyxFinancialHealthScore {
  final int overallScore; // 0 to 100
  final String status;
  final String summary;
  final Color gradeColor;
  final HealthPillar savingsPillar;
  final HealthPillar stabilityPillar;
  final HealthPillar diversificationPillar;
  final HealthPillar liquidityPillar;

  OnyxFinancialHealthScore({
    required this.overallScore,
    required this.status,
    required this.summary,
    required this.gradeColor,
    required this.savingsPillar,
    required this.stabilityPillar,
    required this.diversificationPillar,
    required this.liquidityPillar,
  });

  List<HealthPillar> get pillars => [
        savingsPillar,
        stabilityPillar,
        diversificationPillar,
        liquidityPillar,
      ];
}

class OnyxFinancialHealthService {
  static OnyxFinancialHealthScore calculate({
    required List<Expense> expenses,
    required List<Wallet> wallets,
  }) {
    final totalIncome = expenses
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);

    final totalExpense = expenses
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    double totalWalletBalance =
        wallets.fold(0.0, (sum, item) => sum + item.balance);
    if (wallets.isEmpty && totalIncome > 0) {
      totalWalletBalance =
          (totalIncome - totalExpense).clamp(0.0, double.infinity);
    }

    // 1. Savings Rate Pillar (Max 30 pts)
    double savingsScore = 0.0;
    String savingsTip = 'Record income to gauge savings rate.';
    if (totalIncome > 0) {
      final savings = totalIncome - totalExpense;
      final rate = (savings / totalIncome) * 100;

      if (rate >= 30) {
        savingsScore = 30.0;
        savingsTip = 'Top-tier savings rate (${rate.toStringAsFixed(0)}%). Keep it up!';
      } else if (rate >= 20) {
        savingsScore = 24.0;
        savingsTip = 'Healthy savings rate (${rate.toStringAsFixed(0)}%). Target 30% next.';
      } else if (rate >= 10) {
        savingsScore = 16.0;
        savingsTip = 'Moderate savings (${rate.toStringAsFixed(0)}%). Trim minor wants.';
      } else if (rate >= 0) {
        savingsScore = 8.0;
        savingsTip = 'Breaking even. Build a 10%+ monthly buffer.';
      } else {
        savingsScore = 0.0;
        savingsTip = 'Deficit detected! Spending exceeds total income.';
      }
    } else if (totalExpense == 0) {
      savingsScore = 15.0; // neutral baseline
      savingsTip = 'Add transactions to establish your savings benchmark.';
    }

    // 2. Spending Stability Pillar (Max 25 pts)
    double stabilityScore = 20.0;
    String stabilityTip = 'Spending is steady week-over-week.';
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recent7DaysSpend = expenses
        .where((e) => e.type == 'expense' && e.date.isAfter(sevenDaysAgo))
        .fold(0.0, (sum, item) => sum + item.amount);

    final prior7DaysSpend = expenses
        .where((e) =>
            e.type == 'expense' &&
            e.date.isAfter(fourteenDaysAgo) &&
            e.date.isBefore(sevenDaysAgo))
        .fold(0.0, (sum, item) => sum + item.amount);

    if (prior7DaysSpend > 0) {
      final delta =
          ((recent7DaysSpend - prior7DaysSpend) / prior7DaysSpend) * 100;
      if (delta <= 10 && delta >= -15) {
        stabilityScore = 25.0;
        stabilityTip = 'Very consistent spending week-over-week.';
      } else if (delta < -15) {
        stabilityScore = 23.0;
        stabilityTip = 'Spending decreased nicely compared to last week.';
      } else if (delta <= 35) {
        stabilityScore = 16.0;
        stabilityTip = 'Minor spending surge (+${delta.toStringAsFixed(0)}%) detected.';
      } else {
        stabilityScore = 8.0;
        stabilityTip = 'Large surge (+${delta.toStringAsFixed(0)}%) compared to last week.';
      }
    } else if (expenses.length < 5) {
      stabilityScore = 18.0;
      stabilityTip = 'Record transactions over 2 weeks for full stability score.';
    }

    // 3. Category Diversification (Max 25 pts)
    double diversificationScore = 22.0;
    String diversificationTip = 'Healthy category distribution.';
    final expenseList = expenses.where((e) => e.type == 'expense').toList();
    if (expenseList.isNotEmpty && totalExpense > 0) {
      final Map<String, double> categorySums = {};
      for (final e in expenseList) {
        categorySums[e.category] = (categorySums[e.category] ?? 0.0) + e.amount;
      }
      double highestCategorySpend = 0.0;
      String highestCategoryName = '';
      categorySums.forEach((cat, amount) {
        if (amount > highestCategorySpend) {
          highestCategorySpend = amount;
          highestCategoryName = cat;
        }
      });

      final concentration = (highestCategorySpend / totalExpense) * 100;
      if (concentration <= 35) {
        diversificationScore = 25.0;
        diversificationTip = 'Well-diversified expense allocation.';
      } else if (concentration <= 55) {
        diversificationScore = 18.0;
        diversificationTip = '$highestCategoryName dominates ${concentration.toStringAsFixed(0)}% of expenses.';
      } else {
        diversificationScore = 10.0;
        diversificationTip = 'High concentration in $highestCategoryName (${concentration.toStringAsFixed(0)}%).';
      }
    }

    // 4. Liquidity & Runway (Max 20 pts)
    double liquidityScore = 15.0;
    String liquidityTip = 'Liquid buffer looks healthy.';
    final hasNegativeWallet = wallets.any((w) => w.balance < 0);
    if (hasNegativeWallet) {
      liquidityScore = 2.0;
      liquidityTip = 'Overdraft alert: One or more wallets are negative.';
    } else if (totalWalletBalance <= 0 && totalExpense > 0) {
      liquidityScore = 4.0;
      liquidityTip = 'Very low liquidity. Boost your wallet cash reserves.';
    } else if (totalExpense > 0) {
      final daysElapsed = DateTime.now().day.clamp(1, 31);
      final dailyBurn = totalExpense / daysElapsed;
      if (dailyBurn > 0) {
        final runwayDays = (totalWalletBalance / dailyBurn).round();
        if (runwayDays >= 60) {
          liquidityScore = 20.0;
          liquidityTip = 'Strong safety cushion ($runwayDays+ days runway).';
        } else if (runwayDays >= 30) {
          liquidityScore = 16.0;
          liquidityTip = 'Decent cash runway (~$runwayDays days of expenses).';
        } else if (runwayDays >= 14) {
          liquidityScore = 11.0;
          liquidityTip = 'Tight runway (~$runwayDays days). Keep discretionary spend low.';
        } else {
          liquidityScore = 6.0;
          liquidityTip = 'Low cash runway (<14 days). Prioritize essential bills.';
        }
      }
    } else {
      liquidityScore = 15.0;
      liquidityTip = 'No expenses recorded yet. Runway is stable.';
    }

    final totalScore = (savingsScore +
            stabilityScore +
            diversificationScore +
            liquidityScore)
        .round()
        .clamp(0, 100);

    String status;
    String summary;
    Color gradeColor;

    if (totalScore >= 85) {
      status = 'Financial Master';
      summary =
          'Outstanding discipline! High savings rate and steady cash flow.';
      gradeColor = const Color(0xFF10B981);
    } else if (totalScore >= 70) {
      status = 'Healthy & Resilient';
      summary =
          'Strong finances! You maintain positive savings with solid runway.';
      gradeColor = const Color(0xFF3B82F6);
    } else if (totalScore >= 50) {
      status = 'Moderate Control';
      summary =
          'Fair standing, but higher expense volatility or tight buffer.';
      gradeColor = const Color(0xFFF59E0B);
    } else {
      status = 'Action Needed';
      summary =
          'High spending pressure or deficit. Immediate trimming recommended.';
      gradeColor = const Color(0xFFEF4444);
    }

    return OnyxFinancialHealthScore(
      overallScore: totalScore,
      status: status,
      summary: summary,
      gradeColor: gradeColor,
      savingsPillar: HealthPillar(
        name: 'Savings Rate',
        score: savingsScore,
        maxScore: 30,
        tip: savingsTip,
        color: const Color(0xFF10B981),
      ),
      stabilityPillar: HealthPillar(
        name: 'Spend Stability',
        score: stabilityScore,
        maxScore: 25,
        tip: stabilityTip,
        color: const Color(0xFF6366F1),
      ),
      diversificationPillar: HealthPillar(
        name: 'Budget Balance',
        score: diversificationScore,
        maxScore: 25,
        tip: diversificationTip,
        color: const Color(0xFFEC4899),
      ),
      liquidityPillar: HealthPillar(
        name: 'Cash Runway',
        score: liquidityScore,
        maxScore: 20,
        tip: liquidityTip,
        color: const Color(0xFF06B6D4),
      ),
    );
  }
}
