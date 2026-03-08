abstract class IBudgetService {
  Future<BudgetData> getBudgetData(String sessionId);
}

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

class CategoryBudgetData {
  final String name;
  final int categoryId;
  final int estimated;
  final int spent;

  const CategoryBudgetData({
    required this.name,
    required this.categoryId,
    required this.estimated,
    required this.spent,
  });
}
