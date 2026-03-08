class ShoppingItem {
  final int id;
  final String sessionId;
  final String name;
  final int? categoryId;
  final int quantity;
  final String? unit;
  final double? estPricePerUnit;
  final String? note;
  final String userId;
  final bool isPurchased;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.sessionId,
    required this.name,
    this.categoryId,
    this.quantity = 1,
    this.unit,
    this.estPricePerUnit,
    this.note,
    required this.userId,
    this.isPurchased = false,
    required this.createdAt,
  });
}
