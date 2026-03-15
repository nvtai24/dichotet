import 'package:flutter/material.dart';

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
