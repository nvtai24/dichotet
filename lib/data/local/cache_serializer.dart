import 'dart:convert';
import '../../models/shopping_models.dart';

/// Serialize / deserialize app models to/from JSON strings for Hive storage.
class CacheSerializer {
  // ─── String list ──────────────────────────────────────────────────

  static String encodeStringList(List<String> list) => jsonEncode(list);

  static List<String> decodeStringList(String json) =>
      (jsonDecode(json) as List).cast<String>();

  // ─── ShoppingSession ──────────────────────────────────────────────

  static String encodeSessions(List<ShoppingSession> sessions) =>
      jsonEncode(sessions.map(_sessionToMap).toList());

  static List<ShoppingSession> decodeSessions(String json) =>
      (jsonDecode(json) as List)
          .map((m) => _sessionFromMap(m as Map<String, dynamic>))
          .toList();

  static Map<String, dynamic> _sessionToMap(ShoppingSession s) => {
        'id': s.id,
        'userId': s.userId,
        'name': s.name,
        'budget': s.budget,
        'isActive': s.isActive,
        'createdAt': s.createdAt.toIso8601String(),
      };

  static ShoppingSession _sessionFromMap(Map<String, dynamic> m) =>
      ShoppingSession(
        id: m['id'] as String,
        userId: m['userId'] as String,
        name: m['name'] as String,
        budget: (m['budget'] as num).toDouble(),
        isActive: m['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  // ─── ShoppingCategory ─────────────────────────────────────────────

  static String encodeCategories(List<ShoppingCategory> categories) =>
      jsonEncode(categories.map(_categoryToMap).toList());

  static List<ShoppingCategory> decodeCategories(String json) =>
      (jsonDecode(json) as List)
          .map((m) => _categoryFromMap(m as Map<String, dynamic>))
          .toList();

  static Map<String, dynamic> _categoryToMap(ShoppingCategory c) => {
        'name': c.name,
        'tag': c.tag,
        'isExpanded': c.isExpanded,
        'items': c.items.map(_itemToMap).toList(),
      };

  static ShoppingCategory _categoryFromMap(Map<String, dynamic> m) =>
      ShoppingCategory(
        name: m['name'] as String,
        tag: m['tag'] as String,
        isExpanded: m['isExpanded'] as bool? ?? false,
        items: (m['items'] as List)
            .map((i) => _itemFromMap(i as Map<String, dynamic>))
            .toList(),
      );

  // ─── ShoppingItem ─────────────────────────────────────────────────

  static Map<String, dynamic> _itemToMap(ShoppingItem i) => {
        'name': i.name,
        'categoryName': i.categoryName,
        'categoryTag': i.categoryTag,
        'quantity': i.quantity,
        'unit': i.unit,
        'estimatedPrice': i.estimatedPrice,
        'isHighPriority': i.isHighPriority,
        'note': i.note,
        'imageUrl': i.imageUrl,
        'createdAt': i.createdAt.toIso8601String(),
        'isChecked': i.isChecked,
        'storePrices': i.storePrices.map(_storePriceToMap).toList(),
        'purchases': i.purchases.map(_purchaseToMap).toList(),
      };

  static ShoppingItem _itemFromMap(Map<String, dynamic> m) => ShoppingItem(
        name: m['name'] as String,
        categoryName: m['categoryName'] as String,
        categoryTag: m['categoryTag'] as String,
        quantity: m['quantity'] as int,
        unit: m['unit'] as String,
        estimatedPrice: m['estimatedPrice'] as int,
        isHighPriority: m['isHighPriority'] as bool? ?? false,
        note: m['note'] as String?,
        imageUrl: m['imageUrl'] as String?,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
        isChecked: m['isChecked'] as bool? ?? false,
        storePrices: (m['storePrices'] as List)
            .map((s) => _storePriceFromMap(s as Map<String, dynamic>))
            .toList(),
        purchases: (m['purchases'] as List)
            .map((p) => _purchaseFromMap(p as Map<String, dynamic>))
            .toList(),
      );

  // ─── StoreDetails list ────────────────────────────────────────────

  static String encodeStoreDetails(List<StorePrice> stores) =>
      jsonEncode(stores.map(_storePriceToMap).toList());

  static List<StorePrice> decodeStoreDetails(String json) =>
      (jsonDecode(json) as List)
          .map((m) => _storePriceFromMap(m as Map<String, dynamic>))
          .toList();

  // ─── StorePrice ───────────────────────────────────────────────────

  static Map<String, dynamic> _storePriceToMap(StorePrice s) => {
        'storeId': s.storeId,
        'storeName': s.storeName,
        'pricePerUnit': s.pricePerUnit,
        'lastUpdated': s.lastUpdated,
        'lat': s.lat,
        'lon': s.lon,
      };

  static StorePrice _storePriceFromMap(Map<String, dynamic> m) => StorePrice(
        storeId: m['storeId'] as int?,
        storeName: m['storeName'] as String,
        pricePerUnit: m['pricePerUnit'] as int,
        lastUpdated: m['lastUpdated'] as String,
        lat: (m['lat'] as num?)?.toDouble(),
        lon: (m['lon'] as num?)?.toDouble(),
      );

  // ─── PurchaseRecord ───────────────────────────────────────────────

  static Map<String, dynamic> _purchaseToMap(PurchaseRecord p) => {
        'id': p.id,
        'quantity': p.quantity,
        'pricePerUnit': p.pricePerUnit,
        'purchasedAt': p.purchasedAt.toIso8601String(),
        'locationName': p.locationName,
      };

  static PurchaseRecord _purchaseFromMap(Map<String, dynamic> m) =>
      PurchaseRecord(
        id: m['id'] as int?,
        quantity: m['quantity'] as int,
        pricePerUnit: m['pricePerUnit'] as int,
        purchasedAt: DateTime.parse(m['purchasedAt'] as String),
        locationName: m['locationName'] as String?,
      );
}
