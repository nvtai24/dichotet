import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_shopping_service.dart';

class SupabaseShoppingService implements IShoppingService {
  final SupabaseClient _client;

  SupabaseShoppingService(this._client);

  // ─── Get Categories (with items) ──────────────────────────────────

  @override
  Future<List<ShoppingCategory>> getCategories(String sessionId) async {
    if (_client.auth.currentUser == null) return [];

    // Single query — categories joined inline, no separate round trip
    final itemRows = await _client
        .from('shopping_items')
        .select(
          '*, categories(id, category_name), '
          'item_price_references(*, stores(name, lat, lon)), '
          'purchases(*, stores(name))',
        )
        .eq('session_id', sessionId)
        .order('created_at', ascending: false);

    final Map<int, List<ShoppingItem>> itemsByCategory = {};
    final Map<int, String> catNameById = {};

    for (final row in itemRows) {
      final catId = (row['category_id'] as num?)?.toInt();
      if (catId == null) continue;

      final catData = row['categories'] as Map<String, dynamic>?;
      final catName = catData?['category_name'] as String? ?? '';
      catNameById.putIfAbsent(catId, () => catName);

      final refsRaw = row['item_price_references'] as List<dynamic>? ?? [];
      final storePrices = refsRaw.map((ref) {
        final m = ref as Map<String, dynamic>;
        final storeData = m['stores'] as Map<String, dynamic>?;
        final rawLat = (storeData?['lat'] as num?)?.toDouble();
        final rawLon = (storeData?['lon'] as num?)?.toDouble();
        return StorePrice(
          storeId: (m['store_id'] as num?)?.toInt(),
          storeName: storeData?['name'] as String? ?? '',
          pricePerUnit: (m['price_per_unit'] as num?)?.toInt() ?? 0,
          lastUpdated: 'Đã lưu',
          lat: (rawLat != null && rawLat != -1) ? rawLat : null,
          lon: (rawLon != null && rawLon != -1) ? rawLon : null,
        );
      }).toList();

      final purchasesRaw = row['purchases'] as List<dynamic>? ?? [];
      final purchases = purchasesRaw.map((p) {
        final m = p as Map<String, dynamic>;
        final storeData = m['stores'] as Map<String, dynamic>?;
        return PurchaseRecord(
          id: (m['id'] as num?)?.toInt(),
          quantity: (m['quantity'] as num?)?.toInt() ?? 0,
          pricePerUnit: (m['price_per_unit'] as num?)?.toInt() ?? 0,
          purchasedAt: DateTime.tryParse(m['purchased_at'] as String? ?? '') ?? DateTime.now(),
          locationName: storeData?['name'] as String?,
        );
      }).toList();

      final requiredQty = row['quantity'] as int? ?? 1;
      final totalPurchased = purchases.fold<int>(0, (sum, p) => sum + p.quantity);

      itemsByCategory.putIfAbsent(catId, () => []).add(ShoppingItem(
        id: (row['id'] as num?)?.toInt(),
        name: row['name'] as String,
        categoryName: catName,
        categoryTag: catName.toUpperCase(),
        quantity: requiredQty,
        unit: row['unit'] as String? ?? '',
        estimatedPrice: (row['est_price_per_unit'] as num?)?.toInt() ?? 0,
        note: row['note'] as String?,
        imageUrl: row['image_url'] as String?,
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
        isChecked: totalPurchased >= requiredQty,
        storePrices: storePrices,
        purchases: purchases,
      ));
    }

    // Sort categories by their DB id to preserve consistent ordering
    final sortedIds = catNameById.keys.toList()..sort();
    return [
      for (var i = 0; i < sortedIds.length; i++)
        ShoppingCategory(
          name: catNameById[sortedIds[i]]!,
          tag: catNameById[sortedIds[i]]!.toUpperCase(),
          items: itemsByCategory[sortedIds[i]] ?? [],
          isExpanded: i == 0,
        ),
    ];
  }

  // ─── Get Category Names ───────────────────────────────────────────

  @override
  Future<List<String>> getCategoryNames() async {
    final rows = await _client
        .from('categories')
        .select('category_name')
        .order('id');
    return rows.map((r) => r['category_name'] as String).toList();
  }

  // ─── Get Store Names ──────────────────────────────────────────────

  @override
  Future<List<String>> getStoreNames() async {
    final rows = await _client.from('stores').select('name').order('name');
    final names = rows.map((r) => r['name'] as String).toList();
    if (names.isEmpty) {
      return ['Chợ Bến Thành', 'Lotte Mart', 'Vinmart', 'Chợ địa phương'];
    }
    return names;
  }

  // ─── Get Store Details (with lat/lon) ─────────────────────────────

  @override
  Future<List<StorePrice>> getStoreDetails() async {
    final rows = await _client.from('stores').select('id, name, lat, lon').order('name');
    return rows.map((r) {
      final rawLat = (r['lat'] as num?)?.toDouble();
      final rawLon = (r['lon'] as num?)?.toDouble();
      return StorePrice(
        storeId: (r['id'] as num?)?.toInt(),
        storeName: r['name'] as String,
        pricePerUnit: 0,
        lastUpdated: '',
        lat: (rawLat != null && rawLat != -1) ? rawLat : null,
        lon: (rawLon != null && rawLon != -1) ? rawLon : null,
      );
    }).toList();
  }

  // ─── Add Item ─────────────────────────────────────────────────────

  @override
  Future<void> addItem(
    ShoppingItem item,
    String categoryName,
    String sessionId,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    final catRows = await _client
        .from('categories')
        .select('id')
        .eq('category_name', categoryName)
        .limit(1);
    final categoryId = catRows.isNotEmpty ? catRows.first['id'] as int : null;

    final insertedRows = await _client
        .from('shopping_items')
        .insert({
          'name': item.name,
          'category_id': categoryId,
          'quantity': item.quantity,
          'unit': item.unit,
          'est_price_per_unit': item.estimatedPrice,
          'note': item.note,
          'image_url': item.imageUrl,
          'user_id': userId,
          'session_id': sessionId,
        })
        .select('id');

    if (insertedRows.isNotEmpty && item.storePrices.isNotEmpty) {
      final itemId = insertedRows.first['id'] as int;
      for (final sp in item.storePrices) {
        final storeId = await _findOrCreateStore(sp.storeName, sp.lat, sp.lon);
        await _client.from('item_price_references').insert({
          'shopping_item_id': itemId,
          'store_id': storeId,
          'price_per_unit': sp.pricePerUnit,
        });
      }
    }
  }

  // ─── Update Item ──────────────────────────────────────────────────

  @override
  Future<void> updateItem(
    ShoppingItem oldItem,
    ShoppingItem newItem,
    String categoryName,
  ) async {
    if (oldItem.id == null) throw Exception('Không tìm thấy sản phẩm');
    final itemId = oldItem.id!;

    final catRows = await _client
        .from('categories')
        .select('id')
        .eq('category_name', categoryName)
        .limit(1);
    final categoryId = catRows.isNotEmpty ? catRows.first['id'] as int : null;

    // Parallel: update item + delete old price refs
    await Future.wait([
      _client.from('shopping_items').update({
        'name': newItem.name,
        'category_id': categoryId,
        'quantity': newItem.quantity,
        'unit': newItem.unit,
        'est_price_per_unit': newItem.estimatedPrice,
        'note': newItem.note,
        'image_url': newItem.imageUrl,
      }).eq('id', itemId),
      _client.from('item_price_references').delete().eq('shopping_item_id', itemId),
    ]);

    for (final sp in newItem.storePrices) {
      final storeId = await _findOrCreateStore(sp.storeName, sp.lat, sp.lon);
      await _client.from('item_price_references').insert({
        'shopping_item_id': itemId,
        'store_id': storeId,
        'price_per_unit': sp.pricePerUnit,
      });
    }
  }

  // ─── Update Purchase Status ───────────────────────────────────────

  @override
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    int? actualQuantity,
    int? actualPrice,
    String? locationName,
    double? locationLat,
    double? locationLon,
  }) async {
    if (item.id == null) return;
    final itemId = item.id!;
    final requiredQty = item.quantity;

    if (actualQuantity != null && actualPrice != null) {
      int? storeId;

      if (locationName != null && locationName.isNotEmpty) {
        storeId =
            await _findOrCreateStore(locationName, locationLat, locationLon);

        // Thêm vào item_price_references nếu chưa có
        final existingRef = await _client
            .from('item_price_references')
            .select('id')
            .eq('shopping_item_id', itemId)
            .eq('store_id', storeId)
            .limit(1);

        if (existingRef.isEmpty) {
          await _client.from('item_price_references').insert({
            'shopping_item_id': itemId,
            'store_id': storeId,
            'price_per_unit': actualPrice,
          });
          item.storePrices.add(
            StorePrice(
              storeId: storeId,
              storeName: locationName,
              pricePerUnit: actualPrice,
              lastUpdated: 'Đã lưu',
              lat: locationLat,
              lon: locationLon,
            ),
          );
        }
      }

      final purchaseData = <String, dynamic>{
        'shopping_item_id': itemId,
        'quantity': actualQuantity,
        'price_per_unit': actualPrice,
      };
      if (storeId != null) purchaseData['store_id'] = storeId;
      await _client.from('purchases').insert(purchaseData);

      item.purchases.add(
        PurchaseRecord(
          quantity: actualQuantity,
          pricePerUnit: actualPrice,
          purchasedAt: DateTime.now(),
          locationName: locationName,
        ),
      );
    }

    // Recalculate from in-memory — no extra round trip needed
    final totalPurchased = item.purchases.fold<int>(0, (sum, p) => sum + p.quantity);
    item.isChecked = totalPurchased >= requiredQty;
  }

  // ─── Add Store Price ──────────────────────────────────────────────

  @override
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) async {
    if (item.id == null) return;
    final itemId = item.id!;
    final storeId = await _findOrCreateStore(
      storePrice.storeName,
      storePrice.lat,
      storePrice.lon,
    );
    await _client.from('item_price_references').insert({
      'shopping_item_id': itemId,
      'store_id': storeId,
      'price_per_unit': storePrice.pricePerUnit,
    });
  }

  // ─── Update Purchase ──────────────────────────────────────────────

  @override
  Future<void> updatePurchase(
    int purchaseId,
    int quantity,
    int pricePerUnit,
  ) async {
    await _client
        .from('purchases')
        .update({'quantity': quantity, 'price_per_unit': pricePerUnit})
        .eq('id', purchaseId);
  }

  // ─── Delete Purchase ──────────────────────────────────────────────

  @override
  Future<void> deletePurchase(int purchaseId) async {
    await _client.from('purchases').delete().eq('id', purchaseId);
  }

  // ─── Recalculate Purchase Status ──────────────────────────────────

  @override
  Future<void> recalculatePurchaseStatus(ShoppingItem item) async {
    if (item.id == null) return;
    final itemId = item.id!;
    final requiredQty = item.quantity;

    final purchaseRows = await _client
        .from('purchases')
        .select('quantity')
        .eq('shopping_item_id', itemId);

    final totalPurchased = purchaseRows.fold<int>(
      0,
      (sum, r) => sum + ((r['quantity'] as num?)?.toInt() ?? 0),
    );

    item.isChecked = totalPurchased >= requiredQty;
  }

  // ─── Delete Item ──────────────────────────────────────────────────

  @override
  Future<void> deleteItem(ShoppingItem item) async {
    if (item.id == null) return;
    final itemId = item.id!;

    // Parallel: delete child rows first, then the item
    await Future.wait([
      _client.from('purchases').delete().eq('shopping_item_id', itemId),
      _client.from('item_price_references').delete().eq('shopping_item_id', itemId),
    ]);
    await _client.from('shopping_items').delete().eq('id', itemId);
  }

  // ─── Upload Item Image ────────────────────────────────────────────

  @override
  Future<String> uploadItemImage(Uint8List bytes, String fileName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    final path = '$userId/$fileName';
    await _client.storage.from('item-images').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return _client.storage.from('item-images').getPublicUrl(path);
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  /// Tìm store theo tên, nếu chưa có thì tạo mới. Trả về store_id.
  Future<int> _findOrCreateStore(
    String name,
    double? lat,
    double? lon,
  ) async {
    final trimmed = name.trim();
    final existing = await _client
        .from('stores')
        .select('id')
        .ilike('name', trimmed)
        .limit(1);

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      if (lat != null && lon != null) {
        await _client.from('stores').update({'lat': lat, 'lon': lon}).eq('id', id);
      }
      return id;
    }

    final inserted = await _client
        .from('stores')
        .insert({'name': trimmed, 'lat': lat, 'lon': lon})
        .select('id');
    return inserted.first['id'] as int;
  }
}
