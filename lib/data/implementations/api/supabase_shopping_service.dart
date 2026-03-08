import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_shopping_service.dart';

class SupabaseShoppingService implements IShoppingService {
  final SupabaseClient _client;

  SupabaseShoppingService(this._client);

  // ─── Get Categories (with items) ──────────────────────────────────

  @override
  Future<List<ShoppingCategory>> getCategories() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    // Lấy tất cả categories
    final catRows = await _client.from('categories').select().order('id');

    // Lấy items của user hiện tại, kèm category name, purchase locations và purchases (kèm tên địa điểm)
    final itemRows = await _client
        .from('shopping_items')
        .select(
          '*, categories(category_name), purchase_locations(*), purchases(*, purchase_locations(location_name))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    // Nhóm items theo category
    final Map<int, List<ShoppingItem>> itemsByCategory = {};
    for (final row in itemRows) {
      final catId = row['category_id'] as int?;
      if (catId == null) continue;

      final catName =
          (row['categories'] as Map<String, dynamic>?)?['category_name']
              as String? ??
          '';

      // Parse purchase_locations thành storePrices
      final locationsRaw = row['purchase_locations'] as List<dynamic>? ?? [];
      final storePrices = locationsRaw.map((loc) {
        final m = loc as Map<String, dynamic>;
        return StorePrice(
          storeName: m['location_name'] as String? ?? '',
          type: StoreType.market,
          pricePerUnit: ((m['price_per_unit'] as num?)?.toInt()) ?? 0,
          lastUpdated: 'Đã lưu',
        );
      }).toList();

      // Parse purchases (tất cả bản ghi)
      final purchasesRaw = row['purchases'] as List<dynamic>? ?? [];
      final purchases = purchasesRaw.map((p) {
        final m = p as Map<String, dynamic>;
        final locData = m['purchase_locations'] as Map<String, dynamic>?;
        return PurchaseRecord(
          quantity: (m['quantity'] as num?)?.toInt() ?? 0,
          pricePerUnit: (m['price_per_unit'] as num?)?.toInt() ?? 0,
          purchasedAt:
              DateTime.tryParse(m['purchased_at'] as String? ?? '') ??
              DateTime.now(),
          locationName: locData?['location_name'] as String?,
        );
      }).toList();

      final item = ShoppingItem(
        name: row['name'] as String,
        categoryName: catName,
        categoryTag: catName.toUpperCase(),
        categoryColor: _colorForCategory(catId),
        quantity: row['quantity'] as int? ?? 1,
        unit: row['unit'] as String? ?? '',
        estimatedPrice: ((row['est_price_per_unit'] as num?)?.toInt()) ?? 0,
        note: row['note'] as String?,
        isChecked: row['is_purchased'] as bool? ?? false,
        storePrices: storePrices,
        purchases: purchases,
      );

      itemsByCategory.putIfAbsent(catId, () => []).add(item);
    }

    // Tạo ShoppingCategory list
    final categories = <ShoppingCategory>[];
    for (final cat in catRows) {
      final catId = cat['id'] as int;
      final catName = cat['category_name'] as String;
      categories.add(
        ShoppingCategory(
          name: catName,
          color: _colorForCategory(catId),
          tag: catName.toUpperCase(),
          icon: _iconForCategory(catId),
          items: itemsByCategory[catId] ?? [],
          isExpanded: categories.isEmpty, // expand first
        ),
      );
    }

    return categories;
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
    final rows = await _client
        .from('purchase_locations')
        .select('location_name');
    final names = rows
        .map((r) => r['location_name'] as String)
        .toSet()
        .toList();
    if (names.isEmpty) {
      return ['Chợ Bến Thành', 'Lotte Mart', 'Vinmart', 'Chợ địa phương'];
    }
    return names;
  }

  // ─── Add Item ─────────────────────────────────────────────────────

  @override
  Future<void> addItem(ShoppingItem item, String categoryName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    // Tìm category id
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
          'user_id': userId,
          'is_purchased': false,
        })
        .select('id');

    // Insert purchase locations nếu có
    if (insertedRows.isNotEmpty && item.storePrices.isNotEmpty) {
      final itemId = insertedRows.first['id'] as int;
      final locations = item.storePrices
          .map(
            (sp) => {
              'shopping_item_id': itemId,
              'location_name': sp.storeName,
              'lat': -1,
              'lon': -1,
              'price_per_unit': sp.pricePerUnit,
            },
          )
          .toList();
      await _client.from('purchase_locations').insert(locations);
    }
  }

  // ─── Update Purchase Status ───────────────────────────────────────

  @override
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
    String? locationName,
  }) async {
    // Tìm item theo tên + user
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final rows = await _client
        .from('shopping_items')
        .select('id')
        .eq('name', item.name)
        .eq('user_id', userId)
        .limit(1);

    if (rows.isEmpty) return;

    final itemId = rows.first['id'] as int;

    await _client
        .from('shopping_items')
        .update({'is_purchased': isPurchased})
        .eq('id', itemId);

    // Insert vào bảng purchases
    if (isPurchased && actualQuantity != null && actualPrice != null) {
      int? locationId;

      // Tìm hoặc tạo purchase_location
      if (locationName != null && locationName.isNotEmpty) {
        final existingLoc = await _client
            .from('purchase_locations')
            .select('id')
            .eq('shopping_item_id', itemId)
            .eq('location_name', locationName)
            .limit(1);

        if (existingLoc.isNotEmpty) {
          locationId = existingLoc.first['id'] as int;
        } else {
          final newLoc = await _client
              .from('purchase_locations')
              .insert({
                'shopping_item_id': itemId,
                'location_name': locationName,
                'lat': -1,
                'lon': -1,
                'price_per_unit': actualPrice,
              })
              .select('id');
          if (newLoc.isNotEmpty) {
            locationId = newLoc.first['id'] as int;
            // Cập nhật storePrices in-memory
            item.storePrices.add(
              StorePrice(
                storeName: locationName,
                type: StoreType.market,
                pricePerUnit: actualPrice,
                lastUpdated: 'Đã lưu',
              ),
            );
          }
        }
      }

      final purchaseData = <String, dynamic>{
        'shopping_item_id': itemId,
        'quantity': actualQuantity,
        'price_per_unit': actualPrice,
      };
      if (locationId != null) {
        purchaseData['purchase_location_id'] = locationId;
      }
      await _client.from('purchases').insert(purchaseData);
    }

    item.isChecked = isPurchased;
    if (isPurchased && actualQuantity != null && actualPrice != null) {
      item.purchases.add(
        PurchaseRecord(
          quantity: actualQuantity,
          pricePerUnit: actualPrice,
          purchasedAt: DateTime.now(),
          locationName: locationName,
        ),
      );
    }
  }

  // ─── Add Store Price ──────────────────────────────────────────────

  @override
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) async {
    item.storePrices.add(storePrice);
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  Color _colorForCategory(int id) {
    const colors = [
      Color(0xFFC62828), // red
      Color(0xFF43A047), // green
      Color(0xFFE91E8A), // pink
      Color(0xFFFF6F00), // orange
      Color(0xFF1565C0), // blue
      Color(0xFF6A1B9A), // purple
    ];
    return colors[id % colors.length];
  }

  IconData _iconForCategory(int id) {
    const icons = [
      Icons.card_giftcard_outlined,
      Icons.restaurant_outlined,
      Icons.local_florist_outlined,
      Icons.redeem_outlined,
      Icons.local_cafe_outlined,
      Icons.category_outlined,
    ];
    return icons[id % icons.length];
  }
}
