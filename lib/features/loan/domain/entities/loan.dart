import 'dart:math';
import 'loan_repayment.dart';

class Loan {
  final String id;
  final String userId;
  final String title;
  final String counterparty; // e.g. "City Bank", "John Doe"
  final String type; // 'borrowed' (I owe) or 'lent' (Owed to me)
  final double principal;
  final double interestRate; // % rate (e.g. 5.5, or 0.0 for interest-free)
  final String interestType; // 'none', 'percentage', 'fixed'
  final int tenureMonths; // tenure in months (0 if flexible)
  final DateTime startDate;
  final DateTime? dueDate;
  final String? walletId;
  final String status; // 'active', 'settled', 'overdue'
  final String? notes;
  final Map<String, dynamic> details;
  final List<LoanRepayment> repayments;
  final DateTime createdAt;

  const Loan({
    required this.id,
    required this.userId,
    required this.title,
    required this.counterparty,
    required this.type,
    required this.principal,
    this.interestRate = 0.0,
    this.interestType = 'none',
    this.tenureMonths = 0,
    required this.startDate,
    this.dueDate,
    this.walletId,
    this.status = 'active',
    this.notes,
    this.details = const {},
    this.repayments = const [],
    required this.createdAt,
  });

  bool get isBorrowed => type == 'borrowed';
  bool get isLent => type == 'lent';

  /// Total repayments collected/paid so far
  double get totalPaid {
    return repayments.fold(0.0, (sum, r) => sum + r.amount);
  }

  /// Calculates total interest based on rate and type
  double get totalInterest {
    if (interestType == 'none' || interestRate <= 0) return 0.0;
    if (interestType == 'fixed') {
      return (principal * interestRate) / 100.0;
    }
    // Annual percentage rate over tenure
    final years = tenureMonths > 0 ? (tenureMonths / 12.0) : 1.0;
    return (principal * (interestRate / 100.0) * years);
  }

  /// Total amount required to settle the loan
  double get totalPayable {
    return principal + totalInterest;
  }

  /// Remaining amount due
  double get remainingBalance {
    final rem = totalPayable - totalPaid;
    return rem < 0 ? 0.0 : rem;
  }

  /// Progress of repayment (0.0 to 1.0)
  double get progress {
    if (totalPayable <= 0) return 1.0;
    final p = totalPaid / totalPayable;
    return p.clamp(0.0, 1.0);
  }

  /// Checks if the loan is fully settled
  bool get isSettled {
    return status == 'settled' || (remainingBalance <= 0.01 && totalPaid > 0);
  }

  /// Checks if the loan is overdue
  bool get isOverdue {
    if (isSettled) return false;
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Calculates monthly EMI installment amount
  double get monthlyEmi {
    if (tenureMonths <= 0) return 0.0;
    if (interestRate <= 0 || interestType == 'none') {
      return totalPayable / tenureMonths;
    }
    if (interestType == 'fixed') {
      return totalPayable / tenureMonths;
    }
    // Reducing balance EMI formula: [P * r * (1+r)^n] / [(1+r)^n - 1]
    final monthlyRate = (interestRate / 100.0) / 12.0;
    if (monthlyRate <= 0) return totalPayable / tenureMonths;
    final factor = pow(1 + monthlyRate, tenureMonths).toDouble();
    if (factor <= 1.0) return totalPayable / tenureMonths;
    return (principal * monthlyRate * factor) / (factor - 1);
  }

  Loan copyWith({
    String? id,
    String? userId,
    String? title,
    String? counterparty,
    String? type,
    double? principal,
    double? interestRate,
    String? interestType,
    int? tenureMonths,
    DateTime? startDate,
    DateTime? dueDate,
    String? walletId,
    String? status,
    String? notes,
    Map<String, dynamic>? details,
    List<LoanRepayment>? repayments,
    DateTime? createdAt,
  }) {
    return Loan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      counterparty: counterparty ?? this.counterparty,
      type: type ?? this.type,
      principal: principal ?? this.principal,
      interestRate: interestRate ?? this.interestRate,
      interestType: interestType ?? this.interestType,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      walletId: walletId ?? this.walletId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      details: details ?? this.details,
      repayments: repayments ?? this.repayments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'counterparty': counterparty,
      'type': type,
      'principal': principal,
      'interest_rate': interestRate,
      'interest_type': interestType,
      'tenure_months': tenureMonths,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'wallet_id': walletId,
      'status': isSettled ? 'settled' : status,
      'notes': notes,
      'details': details,
      'repayments': repayments.map((r) => r.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Loan.fromJson(Map<String, dynamic> map) {
    List<LoanRepayment> repList = [];
    if (map['repayments'] is List) {
      repList = (map['repayments'] as List)
          .map((r) => LoanRepayment.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    }

    Map<String, dynamic> det = {};
    if (map['details'] is Map) {
      det = Map<String, dynamic>.from(map['details'] as Map);
    }

    return Loan(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      counterparty: (map['counterparty'] ?? '').toString(),
      type: (map['type'] ?? 'borrowed').toString(),
      principal: (map['principal'] as num?)?.toDouble() ?? 0.0,
      interestRate: (map['interest_rate'] as num?)?.toDouble() ?? 0.0,
      interestType: (map['interest_type'] ?? 'none').toString(),
      tenureMonths: (map['tenure_months'] as num?)?.toInt() ?? 0,
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'].toString())
          : DateTime.now(),
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'].toString())
          : null,
      walletId: map['wallet_id']?.toString(),
      status: (map['status'] ?? 'active').toString(),
      notes: map['notes']?.toString(),
      details: det,
      repayments: repList,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }
}
