import 'package:flutter/material.dart';
import 'shopping_item.dart';

class ShoppingCategory {
  final String name;
  final Color color;
  final String tag;
  final IconData icon;
  final List<ShoppingItem> items;
  bool isExpanded;

  ShoppingCategory({
    required this.name,
    required this.color,
    required this.tag,
    required this.icon,
    required this.items,
    this.isExpanded = false,
  });
}
