import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/i_shopping_repository.dart';
import '../../models/shopping_models.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final IShoppingRepository _repository;

  ShoppingListViewModel(this._repository);

  // ─── State ──────────────────────────────────────────────────────────

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
  int get purchasedItems => allItems.where((i) => i.isChecked).length;

  double get shoppingProgress =>
      totalItems == 0 ? 0.0 : purchasedItems / totalItems;

  int get estimatedBudget =>
      allItems.fold(0, (sum, i) => sum + (i.quantity * i.estimatedPrice));

  int get spentBudget => allItems
      .where((i) => i.isChecked && i.actualPrice != null)
      .fold(0, (sum, i) => sum + i.actualPrice!);

  // ─── Actions ────────────────────────────────────────────────────────

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getCategories(),
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

  Future<void> addItem(ShoppingItem item, String categoryName) async {
    await _repository.addItem(item, categoryName);
    notifyListeners();
  }

  Future<void> confirmPurchase(
    ShoppingItem item, {
    required int quantity,
    required int price,
  }) async {
    await _repository.updateItemPurchaseStatus(
      item,
      isPurchased: true,
      actualQuantity: quantity,
      actualPrice: price,
    );
    notifyListeners();
  }

  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) async {
    await _repository.addStorePrice(item, storePrice);
    notifyListeners();
  }
}
