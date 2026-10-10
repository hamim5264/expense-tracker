class LoanRepayment {
  final String id;
  final String loanId;
  final String userId;
  final double amount;
  final DateTime paymentDate;
  final String? walletId;
  final String? notes;
  final DateTime createdAt;

  const LoanRepayment({
    required this.id,
    required this.loanId,
    required this.userId,
    required this.amount,
    required this.paymentDate,
    this.walletId,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'user_id': userId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'wallet_id': walletId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LoanRepayment.fromJson(Map<String, dynamic> map) {
    return LoanRepayment(
      id: (map['id'] ?? '').toString(),
      loanId: (map['loan_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: map['payment_date'] != null
          ? DateTime.parse(map['payment_date'].toString())
          : DateTime.now(),
      walletId: map['wallet_id']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }
}
