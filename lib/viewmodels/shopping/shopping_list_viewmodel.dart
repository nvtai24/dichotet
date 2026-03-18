import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/i_shopping_repository.dart';
import '../../models/shopping_models.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final IShoppingRepository _repository;

  ShoppingListViewModel(this._repository);

  // ─── State ──────────────────────────────────────────────────────────

  String? _sessionId;
  String? get sessionId => _sessionId;

  List<ShoppingCategory> _categories = [];
  List<ShoppingCategory> get categories => _categories;

  List<String> _categoryNames = [];
  List<String> get categoryNames => _categoryNames;

  List<String> _storeNames = [];
  List<String> get storeNames => _storeNames;

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
    _sessionId = null;
    _categories = [];
    _categoryNames = [];
    _storeNames = [];
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
    notifyListeners();
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
      ]);
      _categories = results[0] as List<ShoppingCategory>;
      _categoryNames = results[1] as List<String>;
      _storeNames = results[2] as List<String>;
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
    // Cache already invalidated by repository
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
    // item mutated in-place by service
    notifyListeners();
  }

  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) async {
    await _repository.addStorePrice(item, storePrice);
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
  }

  Future<void> deletePurchase(int purchaseId, {bool reload = true}) async {
    // Optimistic: remove in-memory
    final item = _findItemByPurchaseId(purchaseId);
    if (item != null) {
      item.purchases.removeWhere((p) => p.id == purchaseId);
      _recalcIsChecked(item);
      notifyListeners();
    }

    await _repository.deletePurchase(purchaseId);
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
          color: item.categoryColor,
          tag: item.categoryTag,
          icon: item.categoryIcon,
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

  ShoppingItem? _findItemByPurchaseId(int purchaseId) {
    for (final cat in _categories) {
      for (final item in cat.items) {
        if (item.purchases.any((p) => p.id == purchaseId)) return item;
      }
    }
    return null;
  }

  void _recalcIsChecked(ShoppingItem item) {
    final total =
        item.purchases.fold<int>(0, (sum, p) => sum + p.quantity);
    item.isChecked = total >= item.quantity;
  }
}
