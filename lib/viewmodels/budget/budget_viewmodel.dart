import 'package:flutter/material.dart';
import '../../data/dtos/budget_dto.dart';
import '../../data/interfaces/repositories/i_budget_repository.dart';
import '../../models/budget_models.dart';
import '../../viewmodels/session/session_viewmodel.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';

class BudgetViewModel extends ChangeNotifier {
  final IBudgetRepository _repository;
  final SessionViewModel _sessionVM;
  final ShoppingListViewModel _shoppingVM;

  BudgetViewModel(this._repository, this._sessionVM, this._shoppingVM) {
    _sessionVM.addListener(_onSessionChanged);
    _shoppingVM.addListener(_onShoppingChanged);
  }

  void _onSessionChanged() {
    final sid = _sessionVM.selectedSession?.id;
    if (sid != null) loadBudget(sid);
  }

  void _onShoppingChanged() {
    final sid = _sessionVM.selectedSession?.id;
    if (sid != null && !_isLoading && !_shoppingVM.isLoading) {
      loadBudget(sid);
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  BudgetData? _data;

  int get totalBudget => _data?.sessionBudget.toInt() ?? 0;
  int get totalEstimated => _data?.totalEstimated ?? 0;
  int get totalSpent => _data?.totalSpent ?? 0;
  int get remaining => totalBudget - totalSpent;
  double get progress => totalBudget == 0 ? 0.0 : totalSpent / totalBudget;

  List<BudgetCategory> get categoryBudgets {
    if (_data == null) return [];
    return _data!.categories
        .map(
          (c) => BudgetCategory(
            label: c.name,
            estimated: c.estimated,
            spent: c.spent,
          ),
        )
        .toList();
  }

  Future<void> loadBudget(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _repository.getBudgetData(sessionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionVM.removeListener(_onSessionChanged);
    _shoppingVM.removeListener(_onShoppingChanged);
    super.dispose();
  }
}
