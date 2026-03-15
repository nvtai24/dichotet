import 'category_budget_data.dart';

class BudgetData {
  final double sessionBudget;
  final int totalEstimated;
  final int totalSpent;
  final List<CategoryBudgetData> categories;

  const BudgetData({
    required this.sessionBudget,
    required this.totalEstimated,
    required this.totalSpent,
    required this.categories,
  });
}
