class PurchaseRecord {
  final int? id;
  final int quantity;
  final int pricePerUnit;
  final DateTime purchasedAt;
  final String? locationName;

  PurchaseRecord({
    this.id,
    required this.quantity,
    required this.pricePerUnit,
    required this.purchasedAt,
    this.locationName,
  });
}
