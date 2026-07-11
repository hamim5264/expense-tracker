import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';

class WalletModel extends Wallet {
  WalletModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.details,
    required super.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> details = {};
    final rawDetails = map['details'];
    if (rawDetails is Map) {
      details = Map<String, dynamic>.from(rawDetails);
    }

    return WalletModel(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      type: (map['type'] ?? 'others').toString(),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      details: details,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  WalletModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    double? balance,
    Map<String, dynamic>? details,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
