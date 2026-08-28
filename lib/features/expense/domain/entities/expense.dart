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
}
