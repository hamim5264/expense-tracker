import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';

class AiInsight {
  final String title;
  final String message;
  final String type;
  final String recommendation;

  AiInsight({
    required this.title,
    required this.message,
    required this.type,
    required this.recommendation,
  });
}

class OnyxAiEngine {
  static List<AiInsight> analyze({
    required List<Expense> expenses,
    required List<Wallet> wallets,
  }) {
    final List<AiInsight> insights = [];

    final totalIncome = expenses
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
    final totalExpense = expenses
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    if (totalIncome > 0) {
      final savings = totalIncome - totalExpense;
      final savingsRate = (savings / totalIncome) * 100;

      if (savingsRate > 20) {
        insights.add(
          AiInsight(
            title: 'Excellent Savings Rate',
            message:
                'You have saved ${savingsRate.toStringAsFixed(1)}% of your total income this period.',
            type: 'success',
            recommendation:
                'Consider moving part of these savings into a dedicated wallet or high-yield repository.',
          ),
        );
      } else if (savingsRate < 0) {
        insights.add(
          AiInsight(
            title: 'Budget Deficit Warning',
            message:
                'Your spending exceeded your income by ${(savingsRate.abs()).toStringAsFixed(1)}%.',
            type: 'warning',
            recommendation:
                'Review your non-essential categories (like Shopping or Entertainment) to balance your budget.',
          ),
        );
      } else {
        insights.add(
          AiInsight(
            title: 'Steady Financial Health',
            message:
                'You saved ${savingsRate.toStringAsFixed(1)}% of your income. You are living within your means.',
            type: 'info',
            recommendation:
                'Try to increase your savings rate to 20% by cutting back on minor subscription services.',
          ),
        );
      }
    } else if (totalExpense > 0) {
      insights.add(
        AiInsight(
          title: 'No Income Tracked Yet',
          message:
              'You have registered \$${totalExpense.toStringAsFixed(2)} in expenses but no income has been recorded yet.',
          type: 'warning',
          recommendation:
              'Add your salary, freelance earnings, or other income streams to get a complete financial analysis.',
        ),
      );
    }

    final expenseTransactions = expenses
        .where((e) => e.type == 'expense')
        .toList();
    if (expenseTransactions.isNotEmpty) {
      final Map<String, double> categorySums = {};
      for (final tx in expenseTransactions) {
        categorySums[tx.category] =
            (categorySums[tx.category] ?? 0.0) + tx.amount;
      }

      var topCategory = '';
      var maxSpend = 0.0;
      categorySums.forEach((category, sum) {
        if (sum > maxSpend) {
          maxSpend = sum;
          topCategory = category;
        }
      });

      final percentage = (maxSpend / totalExpense) * 100;
      if (percentage > 35) {
        insights.add(
          AiInsight(
            title: 'High spending in $topCategory',
            message:
                '$topCategory accounts for ${percentage.toStringAsFixed(1)}% of your total expenses.',
            type: 'warning',
            recommendation:
                'Try setting a weekly limit for $topCategory and cook more at home to lower food costs.',
          ),
        );
      } else {
        insights.add(
          AiInsight(
            title: 'Balanced Expenditures',
            message:
                'Your highest category is $topCategory at ${percentage.toStringAsFixed(1)}% of total spends.',
            type: 'info',
            recommendation:
                'Your category dispersion looks healthy. Keep tracking your daily receipts.',
          ),
        );
      }

      // 1. Week-over-week spending trends
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final fourteenDaysAgo = now.subtract(const Duration(days: 14));

      final recentExpenses = expenseTransactions
          .where((e) => e.date.isAfter(sevenDaysAgo))
          .fold(0.0, (sum, item) => sum + item.amount);

      final priorExpenses = expenseTransactions
          .where((e) => e.date.isAfter(fourteenDaysAgo) && e.date.isBefore(sevenDaysAgo))
          .fold(0.0, (sum, item) => sum + item.amount);

      if (priorExpenses > 0) {
        final change = ((recentExpenses - priorExpenses) / priorExpenses) * 100;
        if (change > 15) {
          insights.add(
            AiInsight(
              title: 'Spike in Weekly Spending',
              message:
                  'Your spending in the last 7 days (\$${recentExpenses.toStringAsFixed(2)}) is ${change.toStringAsFixed(1)}% higher than the previous week (\$${priorExpenses.toStringAsFixed(2)}).',
              type: 'warning',
              recommendation:
                  'Identify what drove this spike and consider delaying non-essential purchases for a few days.',
            ),
          );
        } else if (change < -15) {
          insights.add(
            AiInsight(
              title: 'Great Spending Reduction',
              message:
                  'Fantastic! You spent ${change.abs().toStringAsFixed(1)}% less this week compared to the previous week.',
              type: 'success',
              recommendation:
                  'Keep up this discipline! Put the saved amount into your main wallet or savings goal.',
            ),
          );
        }
      }

      // 2. Subscription/recurring transaction patterns detection
      final expenseMap = <String, List<Expense>>{};
      for (final exp in expenseTransactions) {
        final key = '${exp.category}_${exp.amount.toStringAsFixed(2)}';
        expenseMap.putIfAbsent(key, () => []).add(exp);
      }

      final recurringDetected = <String>[];
      expenseMap.forEach((key, list) {
        if (list.length >= 3) {
          final category = list.first.category;
          final amount = list.first.amount;
          final title = list.first.title;
          recurringDetected.add('$title (\$${amount.toStringAsFixed(2)} in $category)');
        }
      });

      if (recurringDetected.isNotEmpty) {
        insights.add(
          AiInsight(
            title: 'Recurring Charges Detected',
            message:
                'Detected ${recurringDetected.length} potential subscription or recurring payment(s): ${recurringDetected.join(", ")}.',
            type: 'info',
            recommendation:
                'Regularly audit your subscriptions. Cancel any services you no longer actively use.',
          ),
        );
      }
    }

    for (final wallet in wallets) {
      if (wallet.balance < 1000) {
        insights.add(
          AiInsight(
            title: 'Low Balance: ${wallet.name}',
            message:
                'Your ${wallet.name} wallet balance is low at ${wallet.balance.toStringAsFixed(2)}.',
            type: 'warning',
            recommendation:
                'Top up your wallet or avoid using it for large debit payments this week.',
          ),
        );
      }
    }

    if (insights.isEmpty) {
      insights.add(
        AiInsight(
          title: 'Awaiting Financial Data',
          message:
              'Not enough transactions recorded to draw specific insights.',
          type: 'info',
          recommendation:
              'Start adding wallets and recording transactions to let Onyx AI construct your dashboard.',
        ),
      );
    }

    _triggerNotifications(insights);

    return insights;
  }

  static void _triggerNotifications(List<AiInsight> insights) {
    final notificationsService = NotificationService();
    final currentNotifications = notificationsService.notifications;

    for (final insight in insights) {
      if (insight.type == 'warning') {
        final exists = currentNotifications.any(
          (n) =>
              n.title == insight.title &&
              DateTime.now().difference(n.timestamp).inHours < 1,
        );

        if (!exists) {
          notificationsService.addNotification(
            title: 'AI Alert: ${insight.title}',
            message: insight.message,
            type: 'warning',
          );
        }
      }
    }
  }
}
