import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_shopping_service.dart';
import '../../interfaces/repositories/i_shopping_repository.dart';

class ShoppingRepositoryImpl implements IShoppingRepository {
  final IShoppingService _service;

  ShoppingRepositoryImpl(this._service);

  @override
  Future<List<ShoppingCategory>> getCategories() => _service.getCategories();

  @override
  Future<List<String>> getCategoryNames() => _service.getCategoryNames();

  @override
  Future<List<String>> getStoreNames() => _service.getStoreNames();

  @override
  Future<void> addItem(ShoppingItem item, String categoryName) =>
      _service.addItem(item, categoryName);

  @override
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
  }) => _service.updateItemPurchaseStatus(
    item,
    isPurchased: isPurchased,
    actualQuantity: actualQuantity,
    actualPrice: actualPrice,
  );

  @override
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) =>
      _service.addStorePrice(item, storePrice);
}
