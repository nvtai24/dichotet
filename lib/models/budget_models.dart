class BudgetCategory {
  final String label;
  final int estimated;
  final int spent;

  const BudgetCategory({
    required this.label,
    required this.estimated,
    required this.spent,
  });

  double get progress => estimated == 0 ? 0.0 : spent / estimated;
}
