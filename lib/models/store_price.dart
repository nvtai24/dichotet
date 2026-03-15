enum StoreType { market, supermarket, vendor }

class StorePrice {
  final String storeName;
  final StoreType type;
  final int pricePerUnit;
  final String lastUpdated;

  StorePrice({
    required this.storeName,
    required this.type,
    required this.pricePerUnit,
    required this.lastUpdated,
  });
}
