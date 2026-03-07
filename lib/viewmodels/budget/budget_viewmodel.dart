import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';

/// Budget ViewModel – tính toán ngân sách từ danh sách mua sắm.
class BudgetViewModel extends ChangeNotifier {
  final ShoppingListViewModel _shoppingVM;

  BudgetViewModel(this._shoppingVM) {
    _shoppingVM.addListener(_onShoppingChanged);
  }

  void _onShoppingChanged() => notifyListeners();

  // ─── Computed ───────────────────────────────────────────────────────

  int get totalEstimated => _shoppingVM.estimatedBudget;
  int get totalSpent => _shoppingVM.spentBudget;
  int get remaining => totalEstimated - totalSpent;

  double get progress =>
      totalEstimated == 0 ? 0.0 : totalSpent / totalEstimated;

  List<BudgetCategory> get categoryBudgets {
    final categories = _shoppingVM.categories;
    return [
      _buildBudgetCategory(
        categories: categories,
        matchNames: ['Thực phẩm & Đồ uống'],
        label: 'Thực phẩm',
        icon: Icons.restaurant,
        color: AppColors.primary,
      ),
      _buildBudgetCategory(
        categories: categories,
        matchNames: ['Đặc sản Tết'],
        label: 'Bánh kẹo - Mứt',
        icon: Icons.cake,
        color: AppColors.gold,
      ),
      _buildBudgetCategory(
        categories: categories,
        matchNames: ['Trang trí - Hoa'],
        label: 'Trang trí - Hoa',
        icon: Icons.local_florist,
        color: const Color(0xFF2E7D32),
      ),
      _buildBudgetCategory(
        categories: categories,
        matchNames: ['Quà cáp'],
        label: 'Quà cáp',
        icon: Icons.card_giftcard,
        color: const Color(0xFF6A1B9A),
      ),
    ];
  }

  BudgetCategory _buildBudgetCategory({
    required List<ShoppingCategory> categories,
    required List<String> matchNames,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final items = categories
        .where((c) => matchNames.contains(c.name))
        .expand((c) => c.items)
        .toList();

    final estimated = items.fold(
      0,
      (sum, i) => sum + (i.quantity * i.estimatedPrice),
    );
    final spent = items
        .where((i) => i.isChecked && i.actualPrice != null)
        .fold(0, (sum, i) => sum + i.actualPrice!);

    return BudgetCategory(
      label: label,
      icon: icon,
      color: color,
      estimated: estimated,
      spent: spent,
    );
  }

  @override
  void dispose() {
    _shoppingVM.removeListener(_onShoppingChanged);
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
