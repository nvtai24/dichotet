import '../../../models/shopping_models.dart';

/// API layer interface for shopping data.
/// Khi phát triển API thật, tạo class mới implement interface này
/// và gọi Supabase thay vì trả dữ liệu mock.
abstract class IShoppingService {
  Future<List<ShoppingCategory>> getCategories();
  Future<List<String>> getCategoryNames();
  Future<List<String>> getStoreNames();
  Future<void> addItem(ShoppingItem item, String categoryName);
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
  });
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice);
}
