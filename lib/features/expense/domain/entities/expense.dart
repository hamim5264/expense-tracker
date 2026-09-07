class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final String type;
  final String category;
  final String? walletId;
  final String? notes;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.category = 'Others',
    this.walletId,
    this.notes,
  });

  Expense copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    String? type,
    String? category,
    String? walletId,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
      notes: notes ?? this.notes,
    );
  }
}
