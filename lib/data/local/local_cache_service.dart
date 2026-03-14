import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static const _boxName = 'app_cache';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  // ─── Sessions ──────────────────────────────────────────────────────
  void saveSessions(String json) => _box.put('sessions', json);
  String? getSessions() => _box.get('sessions');
  void invalidateSessions() => _box.delete('sessions');

  // ─── Shopping items per session ────────────────────────────────────
  void saveShoppingData(String sessionId, String json) =>
      _box.put('shopping_$sessionId', json);
  String? getShoppingData(String sessionId) =>
      _box.get('shopping_$sessionId');
  void invalidateShoppingData(String sessionId) =>
      _box.delete('shopping_$sessionId');

  // ─── Category names (rarely change) ───────────────────────────────
  void saveCategoryNames(String json) => _box.put('category_names', json);
  String? getCategoryNames() => _box.get('category_names');

  // ─── Store names ───────────────────────────────────────────────────
  void saveStoreNames(String json) => _box.put('store_names', json);
  String? getStoreNames() => _box.get('store_names');

  void clear() => _box.clear();
}
