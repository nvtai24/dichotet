class StorePrice {
  final String storeName;
  final int pricePerUnit;
  final String lastUpdated;
  final double? lat;
  final double? lon;
  final DateTime? createdAt;

  StorePrice({
    required this.storeName,
    required this.pricePerUnit,
    required this.lastUpdated,
    this.lat,
    this.lon,
    this.createdAt,
  });

  bool get hasLocation => lat != null && lon != null && lat != -1 && lon != -1;
}
