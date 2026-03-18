import 'store_price.dart';
import 'purchase_record.dart';

class ShoppingItem {
  final String name;
  final String categoryName;
  final String categoryTag;
  final int quantity;
  final String unit;
  final int estimatedPrice;
  final bool isHighPriority;
  final String? note;
  final String? imageUrl;
  final DateTime createdAt;
  final List<StorePrice> storePrices;
  final List<PurchaseRecord> purchases;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.categoryName,
    required this.categoryTag,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.isHighPriority = false,
    this.note,
    this.imageUrl,
    DateTime? createdAt,
    List<StorePrice>? storePrices,
    List<PurchaseRecord>? purchases,
    this.isChecked = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       storePrices = storePrices ?? [],
       purchases = purchases ?? [];
}
