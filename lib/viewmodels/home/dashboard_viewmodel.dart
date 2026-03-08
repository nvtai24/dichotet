import 'package:flutter/foundation.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/session/session_viewmodel.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';

/// Dashboard ViewModel – derives stats from ShoppingListViewModel.
/// Không gọi repository riêng mà tái sử dụng dữ liệu từ shopping.
class DashboardViewModel extends ChangeNotifier {
  final ShoppingListViewModel _shoppingVM;
  final SessionViewModel _sessionVM;

  DashboardViewModel(this._shoppingVM, this._sessionVM) {
    // Lắng nghe thay đổi từ ShoppingListViewModel & SessionViewModel
    _shoppingVM.addListener(_onChanged);
    _sessionVM.addListener(_onChanged);
  }

  void _onChanged() => notifyListeners();

  // ─── Computed from shopping data ────────────────────────────────────

  int get daysToTet {
    final tetDate = DateTime(2027, 1, 26);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return tetDate.difference(todayOnly).inDays.clamp(0, 9999);
  }

  double get shoppingProgress => _shoppingVM.shoppingProgress;
  int get totalItems => _shoppingVM.totalItems;
  int get purchasedItems => _shoppingVM.purchasedItems;
  int get estimatedBudget => _sessionVM.selectedSession?.budget.toInt() ?? 0;
  int get spentBudget => _shoppingVM.spentBudget;

  String get progressMessage {
    if (shoppingProgress == 0) return 'Chưa có món nào được mua';
    if (shoppingProgress >= 1.0) return 'Đã hoàn thành! 🎉';
    return 'Sắp xong rồi, cố lên!';
  }

  // ─── Recent items ──────────────────────────────────────────────────

  List<ShoppingItem> get recentItems {
    final items = _shoppingVM.allItems;
    if (items.isEmpty) return [];
    final reversed = items.reversed.toList();
    return reversed.take(3).toList();
  }

  @override
  void dispose() {
    _shoppingVM.removeListener(_onChanged);
    _sessionVM.removeListener(_onChanged);
    super.dispose();
  }
}
