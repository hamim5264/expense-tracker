import 'package:expense_tracker/features/expense/domain/entities/expense.dart';

class BudgetPlan {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final String period; // 'monthly' or 'yearly'
  final String category; // 'All' or specific category like 'Food', 'Salary'
  final DateTime startDate;
  final String? walletId;

  BudgetPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.period,
    this.category = 'All',
    required this.startDate,
    this.walletId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'target_amount': targetAmount,
        'period': period,
        'category': category,
        'start_date': startDate.toIso8601String(),
        'wallet_id': walletId,
      };

  factory BudgetPlan.fromJson(Map<String, dynamic> map) => BudgetPlan(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        name: map['name'] as String,
        targetAmount: (map['target_amount'] as num).toDouble(),
        period: map['period'] as String? ?? 'monthly',
        category: map['category'] as String? ?? 'All',
        startDate: map['start_date'] != null
            ? DateTime.parse(map['start_date'] as String)
            : DateTime.now(),
        walletId: map['wallet_id'] as String?,
      );

  // Helper method to calculate spent amount from transactions
  double calculateSpent(List<Expense> expenses) {
    double total = 0.0;
    final now = DateTime.now();

    for (var tx in expenses) {
      if (tx.type != 'expense') continue;

      // Category filter
      if (category != 'All' && tx.category.toLowerCase() != category.toLowerCase()) {
        continue;
      }

      // Wallet filter
      if (walletId != null && tx.walletId != walletId) {
        continue;
      }

      // Period filter
      if (period == 'monthly') {
        if (tx.date.year == now.year && tx.date.month == now.month) {
          total += tx.amount;
        }
      } else {
        if (tx.date.year == now.year) {
          total += tx.amount;
        }
      }
    }
    return total;
  }
}
