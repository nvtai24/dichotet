import 'package:flutter/foundation.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';

/// Dashboard ViewModel – derives stats from ShoppingListViewModel.
/// Không gọi repository riêng mà tái sử dụng dữ liệu từ shopping.
class DashboardViewModel extends ChangeNotifier {
  final ShoppingListViewModel _shoppingVM;

  DashboardViewModel(this._shoppingVM) {
    // Lắng nghe thay đổi từ ShoppingListViewModel
    _shoppingVM.addListener(_onShoppingChanged);
  }

  void _onShoppingChanged() => notifyListeners();

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
  int get estimatedBudget => _shoppingVM.estimatedBudget;
  int get spentBudget => _shoppingVM.spentBudget;

  String get progressMessage {
    if (shoppingProgress == 0) return 'Chưa có món nào được mua';
    if (shoppingProgress >= 1.0) return 'Đã hoàn thành! 🎉';
    return 'Sắp xong rồi, cố lên!';
  }

  // ─── Destinations (mock, sau này lấy từ API) ───────────────────────

  List<Destination> get destinations => const [
    Destination(
      name: 'Chợ Bến Thành',
      category: 'Hoa & Trang trí',
      distance: '0.8km',
      isWalking: true,
    ),
    Destination(
      name: 'Lotte Mart',
      category: 'Thực phẩm & Đồ uống',
      distance: '2.4km',
      isWalking: false,
    ),
  ];

  @override
  void dispose() {
    _shoppingVM.removeListener(_onShoppingChanged);
    super.dispose();
  }
}

class Destination {
  final String name;
  final String category;
  final String distance;
  final bool isWalking;

  const Destination({
    required this.name,
    required this.category,
    required this.distance,
    required this.isWalking,
  });
}
