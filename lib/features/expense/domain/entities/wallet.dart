class Wallet {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.details,
    required this.createdAt,
  });
}
