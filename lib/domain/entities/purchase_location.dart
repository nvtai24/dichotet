class PurchaseLocation {
  final int id;
  final int shoppingItemId;
  final String locationName;
  final double? lat;
  final double? lon;
  final double? pricePerUnit;

  const PurchaseLocation({
    required this.id,
    required this.shoppingItemId,
    required this.locationName,
    this.lat,
    this.lon,
    this.pricePerUnit,
  });
}
