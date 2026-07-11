import 'package:expense_tracker/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.username,
    super.avatarUrl,
    super.currency = 'USD',
    super.smsSyncEnabled = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['full_name'] ?? '',
      username: map['username'],
      avatarUrl: map['avatar_url'],
      currency: map['currency'] ?? 'USD',
      smsSyncEnabled: map['sms_sync_enabled'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? avatarUrl,
    String? currency,
    bool? smsSyncEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      smsSyncEnabled: smsSyncEnabled ?? this.smsSyncEnabled,
    );
  }
}
