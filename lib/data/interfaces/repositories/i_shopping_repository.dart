import '../../../models/shopping_models.dart';

abstract class IShoppingRepository {
  Future<List<ShoppingCategory>> getCategories(String sessionId);
  Future<List<String>> getCategoryNames();
  Future<List<String>> getStoreNames();
  Future<void> addItem(
    ShoppingItem item,
    String categoryName,
    String sessionId,
  );
  Future<void> updateItem(
    ShoppingItem oldItem,
    ShoppingItem newItem,
    String categoryName,
  );
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
    String? locationName,
  });
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice);
  Future<void> updatePurchase(int purchaseId, int quantity, int pricePerUnit);
  Future<void> deletePurchase(int purchaseId);
  Future<void> recalculatePurchaseStatus(ShoppingItem item);
  Future<void> deleteItem(ShoppingItem item);
}
