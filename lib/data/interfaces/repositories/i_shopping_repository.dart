import '../../../models/shopping_models.dart';

abstract class IShoppingRepository {
  Future<List<ShoppingCategory>> getCategories();
  Future<List<String>> getCategoryNames();
  Future<List<String>> getStoreNames();
  Future<void> addItem(ShoppingItem item, String categoryName);
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
    String? locationName,
  });
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice);
}
