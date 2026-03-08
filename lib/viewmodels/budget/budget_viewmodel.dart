import 'package:flutter/material.dart';
import '../../data/interfaces/api/i_budget_service.dart';
import '../../data/interfaces/repositories/i_budget_repository.dart';
import '../../viewmodels/session/session_viewmodel.dart';

class BudgetViewModel extends ChangeNotifier {
  final IBudgetRepository _repository;
  final SessionViewModel _sessionVM;

  BudgetViewModel(this._repository, this._sessionVM) {
    _sessionVM.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    final sid = _sessionVM.selectedSession?.id;
    if (sid != null) loadBudget(sid);
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
            icon: _iconForCategory(c.categoryId),
            color: _colorForCategory(c.categoryId),
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

  static Color _colorForCategory(int id) {
    const colors = [
      Color(0xFFC62828),
      Color(0xFF43A047),
      Color(0xFFE91E8A),
      Color(0xFFFF6F00),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
    ];
    return colors[id % colors.length];
  }

  static IconData _iconForCategory(int id) {
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

  @override
  void dispose() {
    _sessionVM.removeListener(_onSessionChanged);
    super.dispose();
  }
}

class BudgetCategory {
  final String label;
  final IconData icon;
  final Color color;
  final int estimated;
  final int spent;

  const BudgetCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.estimated,
    required this.spent,
  });

  double get progress => estimated == 0 ? 0.0 : spent / estimated;
}
