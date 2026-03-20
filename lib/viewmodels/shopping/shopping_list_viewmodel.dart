import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/interfaces/repositories/i_shopping_repository.dart';
import '../../data/interfaces/repositories/i_session_repository.dart';
import '../../models/shopping_models.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final IShoppingRepository _repository;
  final ISessionRepository? _sessionRepository;

  ShoppingListViewModel(this._repository, {ISessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository;

  // Fire-and-forget: log an action without breaking the main flow
  void _logAction(
    String actionType, {
    int? itemId,
    String? itemName,
    Map<String, dynamic>? metadata,
  }) {
    final sid = _sessionId;
    final repo = _sessionRepository;
    if (sid == null || repo == null) return;
    repo
        .addLog(
          sessionId: sid,
          actionType: actionType,
          itemId: itemId,
          itemName: itemName,
          metadata: metadata,
        )
        .catchError((_) {});
  }

  // ─── State ──────────────────────────────────────────────────────────

  String? _sessionId;
  String? get sessionId => _sessionId;

  RealtimeChannel? _realtimeChannel;

  List<ShoppingCategory> _categories = [];
  List<ShoppingCategory> get categories => _categories;

  List<String> _categoryNames = [];
  List<String> get categoryNames => _categoryNames;

  List<String> _storeNames = [];
  List<String> get storeNames => _storeNames;

  List<StorePrice> _storeDetails = [];
  List<StorePrice> get storeDetails => _storeDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _activeTab = 0; // 0: All, 1: Pending, 2: Purchased
  int get activeTab => _activeTab;

  // ─── Computed ───────────────────────────────────────────────────────

  List<ShoppingItem> get allItems =>
      _categories.expand((c) => c.items).toList();

  /// Tên cửa hàng chỉ từ items trong phiên hiện tại (không lấy global)
  List<String> get sessionStoreNames {
    final seen = <String>{};
    final names = <String>[];
    for (final cat in _categories) {
      for (final item in cat.items) {
        for (final sp in item.storePrices) {
          if (seen.add(sp.storeName)) names.add(sp.storeName);
        }
      }
    }
    return names;
  }

  int get totalItems => allItems.length;

  /// Số item đã mua đủ số lượng (dùng để hiển thị "x/y mặt hàng")
  int get purchasedItems => allItems.where((i) => i.isChecked).length;

  /// Tiến độ theo số vật phẩm: số item đã mua đủ / tổng số item
  double get shoppingProgress {
    if (totalItems == 0) return 0.0;
    return (purchasedItems / totalItems).clamp(0.0, 1.0);
  }

  int get estimatedBudget =>
      allItems.fold(0, (sum, i) => sum + (i.quantity * i.estimatedPrice));

  int get spentBudget => allItems
      .where((i) => i.purchases.isNotEmpty)
      .fold(
        0,
        (sum, i) =>
            sum +
            i.purchases.fold(0, (s, p) => s + p.quantity * p.pricePerUnit),
      );

  // ─── Session ────────────────────────────────────────────────────────

  void reset() {
    _unsubscribeRealtime();
    _sessionId = null;
    _categories = [];
    _categoryNames = [];
    _storeNames = [];
    _storeDetails = [];
    _searchQuery = '';
    _activeTab = 0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void setSessionId(String sessionId) {
    if (_sessionId == sessionId) return;
    _sessionId = sessionId;
    _categories = [];
    _subscribeRealtime();
    notifyListeners();
  }

  void _subscribeRealtime() {
    _realtimeChannel?.unsubscribe();
    if (_sessionId == null) return;
    _realtimeChannel = Supabase.instance.client
        .channel('shopping:$_sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: _sessionId!,
          ),
          callback: (_) {
            if (_sessionId != null) {
              _repository.invalidateSessionCache(_sessionId!);
              loadData();
            }
          },
        )
        .subscribe();
  }

  void _unsubscribeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  // ─── Load (cache-first via repository) ──────────────────────────────

  Future<void> loadData() async {
    if (_sessionId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getCategories(_sessionId!),
        _repository.getCategoryNames(),
        _repository.getStoreNames(),
        _repository.getStoreDetails(),
      ]);
      _categories = results[0] as List<ShoppingCategory>;
      _categoryNames = results[1] as List<String>;
      _storeNames = results[2] as List<String>;
      _storeDetails = results[3] as List<StorePrice>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force fresh data from API (e.g. pull-to-refresh)
  Future<void> forceRefresh() async {
    if (_sessionId == null) return;
    _repository.invalidateSessionCache(_sessionId!);
    await loadData();
  }

  /// Fetch category names trực tiếp từ API (bỏ qua cache)
  Future<List<String>> fetchFreshCategoryNames() async {
    _repository.invalidateCategoryNamesCache();
    final names = await _repository.getCategoryNames();
    _categoryNames = names;
    notifyListeners();
    return names;
  }

  // ─── UI state ───────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveTab(int tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void toggleCategoryExpand(ShoppingCategory category) {
    category.isExpanded = !category.isExpanded;
    notifyListeners();
  }

  bool itemMatchesTab(ShoppingItem item) {
    if (_activeTab == 1) return !item.isChecked;
    if (_activeTab == 2) return item.isChecked;
    return true;
  }

  bool itemMatchesSearch(ShoppingItem item) {
    if (_searchQuery.isEmpty) return true;
    return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  List<ShoppingItem> visibleItems(ShoppingCategory category) {
    return category.items
        .where((i) => itemMatchesTab(i) && itemMatchesSearch(i))
        .toList();
  }

  // ─── CRUD (optimistic updates) ───────────────────────────────────────

  Future<void> addItem(ShoppingItem item, String categoryName) async {
    if (_sessionId == null) return;

    // Optimistic: add to local state immediately
    _addItemToCategory(item, categoryName);
    notifyListeners();

    await _repository.addItem(item, categoryName, _sessionId!);
    _logAction('add_item', itemName: item.name);
    _syncStorePrices(item.storePrices);
  }

  Future<void> updateItem(
    ShoppingItem oldItem,
    ShoppingItem newItem,
    String categoryName,
  ) async {
    // Optimistic: replace in local state
    _replaceItem(oldItem, newItem, categoryName);
    notifyListeners();

    await _repository.updateItem(oldItem, newItem, categoryName);
    if (_sessionId != null) _repository.invalidateSessionCache(_sessionId!);
    _logAction('update_item', itemName: newItem.name,
        metadata: oldItem.name != newItem.name ? {'old_name': oldItem.name} : null);
    _syncStorePrices(newItem.storePrices);
  }

  Future<void> confirmPurchase(
    ShoppingItem item, {
    required int quantity,
    required int price,
    String? locationName,
    double? locationLat,
    double? locationLon,
  }) async {
    await _repository.updateItemPurchaseStatus(
      item,
      isPurchased: true,
      actualQuantity: quantity,
      actualPrice: price,
      locationName: locationName,
      locationLat: locationLat,
      locationLon: locationLon,
    );
    if (_sessionId != null) _repository.invalidateSessionCache(_sessionId!);
    _logAction('check_item', itemName: item.name,
        metadata: {'store': locationName, 'price': price});
    if (locationName != null && locationLat != null && locationLon != null) {
      _syncStorePrices([StorePrice(
        storeName: locationName,
        pricePerUnit: 0,
        lastUpdated: '',
        lat: locationLat,
        lon: locationLon,
      )]);
    }
    notifyListeners();
  }

  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) async {
    await _repository.addStorePrice(item, storePrice);
    if (_sessionId != null) _repository.invalidateSessionCache(_sessionId!);
    _syncStorePrices([storePrice]);
    _logAction('add_price',
        itemName: item.name,
        metadata: {
          'store': storePrice.storeName,
          'price': storePrice.pricePerUnit,
        });
    notifyListeners();
  }

  Future<void> updatePurchase(
    int purchaseId,
    int quantity,
    int pricePerUnit, {
    bool reload = true,
  }) async {
    // Optimistic: update in-memory
    final item = _findItemByPurchaseId(purchaseId);
    if (item != null) {
      final idx = item.purchases.indexWhere((p) => p.id == purchaseId);
      if (idx != -1) {
        item.purchases[idx] = PurchaseRecord(
          id: purchaseId,
          quantity: quantity,
          pricePerUnit: pricePerUnit,
          purchasedAt: item.purchases[idx].purchasedAt,
          locationName: item.purchases[idx].locationName,
        );
        _recalcIsChecked(item);
        notifyListeners();
      }
    }

    await _repository.updatePurchase(purchaseId, quantity, pricePerUnit);
    if (_sessionId != null) _repository.invalidateSessionCache(_sessionId!);
    if (item != null) {
      final purchase = item.purchases.firstWhere((p) => p.id == purchaseId,
          orElse: () => item.purchases.first);
      _logAction('update_purchase',
          itemName: item.name,
          metadata: {
            'store': purchase.locationName,
            'price': pricePerUnit,
          });
    }
  }

  Future<void> deletePurchase(int purchaseId, {bool reload = true}) async {
    // Capture item name before optimistic remove
    final item = _findItemByPurchaseId(purchaseId);
    final itemName = item?.name;
    final purchase = item?.purchases.firstWhere((p) => p.id == purchaseId,
        orElse: () => item.purchases.first);

    item?.purchases.removeWhere((p) => p.id == purchaseId);
    if (item != null) _recalcIsChecked(item);
    notifyListeners();

    await _repository.deletePurchase(purchaseId);
    if (_sessionId != null) _repository.invalidateSessionCache(_sessionId!);
    _logAction('uncheck_item',
        itemName: itemName,
        metadata: {'store': purchase?.locationName});
  }

  Future<void> recalculatePurchaseStatus(ShoppingItem item) async {
    await _repository.recalculatePurchaseStatus(item);
    // item.isChecked mutated in-place by service
    notifyListeners();
  }

  Future<String> uploadItemImage(Uint8List bytes, String fileName) =>
      _repository.uploadItemImage(bytes, fileName);

  Future<void> deleteItem(ShoppingItem item) async {
    // Optimistic: remove locally
    for (final cat in _categories) {
      cat.items.remove(item);
    }
    _categories.removeWhere((c) => c.items.isEmpty);
    notifyListeners();

    await _repository.deleteItem(item);
    if (_sessionId != null) _repository.invalidateSessionCache(_sessionId!);
    _logAction('delete_item', itemName: item.name);
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  void _addItemToCategory(ShoppingItem item, String categoryName) {
    final existing = _categories.where((c) => c.name == categoryName).toList();
    if (existing.isNotEmpty) {
      existing.first.items.insert(0, item);
    } else {
      _categories.insert(
        0,
        ShoppingCategory(
          name: categoryName,
          tag: item.categoryTag,
          items: [item],
          isExpanded: true,
        ),
      );
    }
  }

  void _replaceItem(
      ShoppingItem oldItem, ShoppingItem newItem, String categoryName) {
    // Remove from old category
    for (final cat in _categories) {
      cat.items.remove(oldItem);
    }
    _categories.removeWhere((c) => c.items.isEmpty);
    // Add to new category
    _addItemToCategory(newItem, categoryName);
  }

  /// Tìm StorePrice khớp tên (case-insensitive).
  /// Ưu tiên _storeDetails (full store table với lat/lon đầy đủ),
  /// fallback về storePrices của items trong session.
  StorePrice? findStore(String name) {
    final lower = name.toLowerCase();
    for (final s in _storeDetails) {
      if (s.storeName.toLowerCase() == lower) return s;
    }
    for (final cat in _categories) {
      for (final item in cat.items) {
        for (final sp in item.storePrices) {
          if (sp.storeName.toLowerCase() == lower) return sp;
        }
      }
    }
    return null;
  }

  ShoppingItem? _findItemByPurchaseId(int purchaseId) {
    for (final cat in _categories) {
      for (final item in cat.items) {
        if (item.purchases.any((p) => p.id == purchaseId)) return item;
      }
    }
    return null;
  }

  /// Cập nhật lat/lon của stores trong _storeDetails mà không cần gọi lại API.
  void _syncStorePrices(List<StorePrice> storePrices) {
    for (final sp in storePrices) {
      if (sp.lat == null || sp.lon == null) continue;
      final idx = _storeDetails.indexWhere(
        (s) => s.storeName.toLowerCase() == sp.storeName.toLowerCase(),
      );
      if (idx >= 0) {
        _storeDetails[idx] = StorePrice(
          storeId: _storeDetails[idx].storeId,
          storeName: _storeDetails[idx].storeName,
          pricePerUnit: 0,
          lastUpdated: '',
          lat: sp.lat,
          lon: sp.lon,
        );
      } else {
        _storeDetails.add(StorePrice(
          storeName: sp.storeName,
          pricePerUnit: 0,
          lastUpdated: '',
          lat: sp.lat,
          lon: sp.lon,
        ));
      }
    }
  }

  void _recalcIsChecked(ShoppingItem item) {
    final total =
        item.purchases.fold<int>(0, (sum, p) => sum + p.quantity);
    item.isChecked = total >= item.quantity;
  }
}
