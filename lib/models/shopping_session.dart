class ShoppingSession {
  final String id;
  final String userId;
  final String name;
  final double budget;
  final bool isActive;
  final DateTime createdAt;
  final String? joinCode;
  final bool isShared;

  ShoppingSession({
    required this.id,
    required this.userId,
    required this.name,
    required this.budget,
    this.isActive = true,
    required this.createdAt,
    this.joinCode,
    this.isShared = false,
  });

  bool isOwnedBy(String userId) => this.userId == userId;
}
