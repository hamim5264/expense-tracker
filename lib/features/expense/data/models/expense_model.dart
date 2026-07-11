import 'package:expense_tracker/features/expense/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.date,
    required super.type,
    super.category = 'Others',
    super.walletId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'wallet_id': walletId,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      category: map['category'] as String? ?? 'Others',
      walletId: map['wallet_id'] as String?,
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    String? type,
    String? category,
    String? walletId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
    );
  }
}
