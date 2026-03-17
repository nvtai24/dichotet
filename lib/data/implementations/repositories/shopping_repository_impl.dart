import 'dart:typed_data';
import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_shopping_service.dart';
import '../../interfaces/repositories/i_shopping_repository.dart';
import '../../local/local_cache_service.dart';
import '../../local/cache_serializer.dart';

class ShoppingRepositoryImpl implements IShoppingRepository {
  final IShoppingService _service;
  final LocalCacheService _cache;

  ShoppingRepositoryImpl(this._service, this._cache);

  // ─── Reads (cache-first) ──────────────────────────────────────────

  @override
  Future<List<ShoppingCategory>> getCategories(String sessionId) async {
    final cached = _cache.getShoppingData(sessionId);
    if (cached != null) {
      // Return cache immediately, refresh in background
      _service.getCategories(sessionId).then((fresh) {
        _cache.saveShoppingData(
            sessionId, CacheSerializer.encodeCategories(fresh));
      }).catchError((_) {});
      return CacheSerializer.decodeCategories(cached);
    }
    // Cache miss: fetch from API and store
    final result = await _service.getCategories(sessionId);
    _cache.saveShoppingData(sessionId, CacheSerializer.encodeCategories(result));
    return result;
  }

  @override
  Future<List<String>> getCategoryNames() async {
    final cached = _cache.getCategoryNames();
    if (cached != null) return CacheSerializer.decodeStringList(cached);
    final result = await _service.getCategoryNames();
    _cache.saveCategoryNames(CacheSerializer.encodeStringList(result));
    return result;
  }

  @override
  Future<List<String>> getStoreNames() async {
    final cached = _cache.getStoreNames();
    if (cached != null) {
      _service.getStoreNames().then((fresh) {
        _cache.saveStoreNames(CacheSerializer.encodeStringList(fresh));
      }).catchError((_) {});
      return CacheSerializer.decodeStringList(cached);
    }
    final result = await _service.getStoreNames();
    _cache.saveStoreNames(CacheSerializer.encodeStringList(result));
    return result;
  }

  // ─── Writes (API + invalidate cache) ─────────────────────────────

  @override
  Future<void> addItem(
      ShoppingItem item, String categoryName, String sessionId) async {
    await _service.addItem(item, categoryName, sessionId);
    _cache.invalidateShoppingData(sessionId);
  }

  @override
  Future<void> updateItem(
      ShoppingItem oldItem, ShoppingItem newItem, String categoryName) =>
      _service.updateItem(oldItem, newItem, categoryName);

  @override
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
    String? locationName,
  }) =>
      _service.updateItemPurchaseStatus(
        item,
        isPurchased: isPurchased,
        actualQuantity: actualQuantity,
        actualPrice: actualPrice,
        locationName: locationName,
      );

  @override
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) =>
      _service.addStorePrice(item, storePrice);

  @override
  Future<void> updatePurchase(
          int purchaseId, int quantity, int pricePerUnit) =>
      _service.updatePurchase(purchaseId, quantity, pricePerUnit);

  @override
  Future<void> deletePurchase(int purchaseId) =>
      _service.deletePurchase(purchaseId);

  @override
  Future<void> recalculatePurchaseStatus(ShoppingItem item) =>
      _service.recalculatePurchaseStatus(item);

  @override
  Future<void> deleteItem(ShoppingItem item) => _service.deleteItem(item);

  @override
  Future<String> uploadItemImage(Uint8List bytes, String fileName) =>
      _service.uploadItemImage(bytes, fileName);

  @override
  void invalidateSessionCache(String sessionId) =>
      _cache.invalidateShoppingData(sessionId);
}
