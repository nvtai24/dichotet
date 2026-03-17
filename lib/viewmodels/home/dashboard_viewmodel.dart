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

  // Ngày mùng 1 Tết Nguyên Đán (Âm lịch → Dương lịch)
  static final List<DateTime> _tetDates = [
    DateTime(2025, 1, 29), // Tết Ất Tỵ 2025
    DateTime(2026, 2, 17), // Tết Bính Ngọ 2026
    DateTime(2027, 2, 6), // Tết Đinh Mùi 2027
    DateTime(2028, 1, 26), // Tết Mậu Thân 2028
    DateTime(2029, 2, 13), // Tết Kỷ Dậu 2029
    DateTime(2030, 2, 3), // Tết Canh Tuất 2030
    DateTime(2031, 1, 23), // Tết Tân Hợi 2031
    DateTime(2032, 2, 11), // Tết Nhâm Tý 2032
    DateTime(2033, 1, 31), // Tết Quý Sửu 2033
    DateTime(2034, 2, 19), // Tết Giáp Dần 2034
  ];

  DateTime get _nextTet {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    for (final tet in _tetDates) {
      if (tet.isAfter(todayOnly)) return tet;
    }
    return _tetDates.last;
  }

  int get tetYear => _nextTet.year;

  /// Trả về tên Can Chi của năm Tết sắp tới, vd: "Đinh Mùi 🐐"
  String get tetZodiac {
    const can = ['Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu', 'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý'];
    const chi = ['Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ', 'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi'];
    const emoji = ['🐭', '🐮', '🐯', '🐰', '🐉', '🐍', '🐴', '🐐', '🐒', '🐓', '🐕', '🐗'];
    final y = tetYear;
    final canName = can[(y - 4) % 10];
    final chiIdx = (y - 4) % 12;
    return '$canName ${chi[chiIdx]} ${emoji[chiIdx]}';
  }

  int get daysToTet {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return _nextTet.difference(todayOnly).inDays.clamp(0, 9999);
  }

  double get shoppingProgress => _shoppingVM.shoppingProgress;
  int get totalItems => _shoppingVM.totalItems;
  int get purchasedItems => _shoppingVM.purchasedItems;
  int get estimatedBudget => _sessionVM.selectedSession?.budget.toInt() ?? 0;
  int get listEstimate => _shoppingVM.estimatedBudget;
  int get spentBudget => _shoppingVM.spentBudget;

  String get progressMessage {
    if (shoppingProgress == 0) return 'Chưa có món nào được mua';
    if (shoppingProgress > 0 && shoppingProgress < 1.0)
      return 'Đã mua $purchasedItems/$totalItems món';
    if (shoppingProgress >= 1.0) return 'Đã hoàn thành! 🎉';
    return 'Sắp xong rồi, cố lên!';
  }

  // ─── Recent items ──────────────────────────────────────────────────

  List<ShoppingItem> get recentItems {
    final items = _shoppingVM.allItems;
    if (items.isEmpty) return [];
    final sorted = [...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  @override
  void dispose() {
    _shoppingVM.removeListener(_onChanged);
    _sessionVM.removeListener(_onChanged);
    super.dispose();
  }
}
