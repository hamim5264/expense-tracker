class User {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? avatarUrl;
  final String currency;
  final bool smsSyncEnabled;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.avatarUrl,
    this.currency = 'USD',
    this.smsSyncEnabled = false,
  });
}
