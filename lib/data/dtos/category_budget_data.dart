class CategoryBudgetData {
  final String name;
  final int categoryId;
  final String? iconName;
  final String? colorHex;
  final int estimated;
  final int spent;

  const CategoryBudgetData({
    required this.name,
    required this.categoryId,
    this.iconName,
    this.colorHex,
    required this.estimated,
    required this.spent,
  });
}
