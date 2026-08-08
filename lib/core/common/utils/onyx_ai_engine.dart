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
                'Consider moving part of these savings into a dedicated wallet or high-yield goal.',
          ),
        );
      } else if (savingsRate < 0) {
        final deficitAmount = totalExpense - totalIncome;
        insights.add(
          AiInsight(
            title: 'Budget Deficit Alert',
            message:
                'Your spending exceeds your total income by ${deficitAmount.toStringAsFixed(2)}. You are spending more than you earn.',
            type: 'warning',
            recommendation:
                'Review your non-essential categories (like Shopping or Entertainment) to bring your budget back into balance.',
          ),
        );
      } else {
        insights.add(
          AiInsight(
            title: 'Steady Financial Health',
            message:
                'You saved ${savingsRate.toStringAsFixed(1)}% of your income. You are living comfortably within your means.',
            type: 'info',
            recommendation:
                'Try to boost your monthly savings rate to 20% by trimming minor subscription expenses.',
          ),
        );
      }
    } else if (totalExpense > 0) {
      insights.add(
        AiInsight(
          title: 'Unbalanced Cash Flow',
          message:
              'You have registered ${totalExpense.toStringAsFixed(2)} in total expenses with zero recorded income.',
          type: 'warning',
          recommendation:
              'Record your salary, freelance earnings, or secondary income to get precise cash flow analysis.',
        ),
      );
    }

    final expenseTransactions = expenses
        .where((e) => e.type == 'expense')
        .toList();
    if (expenseTransactions.isNotEmpty && totalExpense > 0) {
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
            title: 'High Spending: $topCategory',
            message:
                '$topCategory makes up ${percentage.toStringAsFixed(1)}% (${maxSpend.toStringAsFixed(2)}) of your overall expenses.',
            type: 'warning',
            recommendation:
                'Consider setting a weekly limit for $topCategory to maintain balanced category distribution.',
          ),
        );
      } else {
        insights.add(
          AiInsight(
            title: 'Balanced Expense Allocation',
            message:
                'Your top category is $topCategory taking ${percentage.toStringAsFixed(1)}% of total spends.',
            type: 'info',
            recommendation:
                'Your spending distribution across categories is well balanced. Keep it up!',
          ),
        );
      }

      // 1. Week-over-week spending trends with ratio caps
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
        final rawChange = ((recentExpenses - priorExpenses) / priorExpenses) * 100;
        final change = rawChange.clamp(-100.0, 500.0);
        if (change > 15) {
          insights.add(
            AiInsight(
              title: 'Weekly Spending Surge',
              message:
                  'Your 7-day spending (${recentExpenses.toStringAsFixed(2)}) is ${change.toStringAsFixed(1)}% higher than last week (${priorExpenses.toStringAsFixed(2)}).',
              type: 'warning',
              recommendation:
                  'Check recent transactions to pinpoint what drove this week\'s spending surge.',
            ),
          );
        } else if (change < -15) {
          insights.add(
            AiInsight(
              title: 'Reduced Weekly Expenses',
              message:
                  'Great job! You spent ${change.abs().toStringAsFixed(1)}% less this week compared to last week.',
              type: 'success',
              recommendation:
                  'Keep up the disciplined spending! Consider allocating extra funds to your savings goal.',
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
          recurringDetected.add('$title (${amount.toStringAsFixed(2)} in $category)');
        }
      });

      if (recurringDetected.isNotEmpty) {
        insights.add(
          AiInsight(
            title: 'Recurring Subscriptions Detected',
            message:
                'Found ${recurringDetected.length} potential subscription or recurring charges: ${recurringDetected.join(", ")}.',
            type: 'info',
            recommendation:
                'Regularly review recurring charges to cancel services you no longer actively use.',
          ),
        );
      }
    }

    for (final wallet in wallets) {
      if (wallet.balance < 0) {
        insights.add(
          AiInsight(
            title: 'Negative Balance: ${wallet.name}',
            message:
                'Your ${wallet.name} wallet balance is negative at ${wallet.balance.toStringAsFixed(2)}.',
            type: 'warning',
            recommendation:
                'Top up this wallet immediately to avoid overdraft fees or negative account debt.',
          ),
        );
      } else if (wallet.balance < 500) {
        insights.add(
          AiInsight(
            title: 'Low Balance: ${wallet.name}',
            message:
                'Your ${wallet.name} wallet balance is low at ${wallet.balance.toStringAsFixed(2)}.',
            type: 'info',
            recommendation:
                'Ensure you have sufficient liquidity before making big upcoming purchases.',
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
