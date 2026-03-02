class Purchase {
  final int id;
  final int shoppingItemId;
  final int quantity;
  final double? pricePerUnit;
  final DateTime purchasedAt;

  const Purchase({
    required this.id,
    required this.shoppingItemId,
    required this.quantity,
    this.pricePerUnit,
    required this.purchasedAt,
  });
}
