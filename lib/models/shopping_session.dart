class ShoppingSession {
  final String id;
  final String userId;
  final String name;
  final double budget;
  final bool isActive;
  final DateTime createdAt;

  ShoppingSession({
    required this.id,
    required this.userId,
    required this.name,
    required this.budget,
    this.isActive = true,
    required this.createdAt,
  });
}
