import 'shopping_item.dart';

class ShoppingCategory {
  final String name;
  final String tag;
  final List<ShoppingItem> items;
  bool isExpanded;

  ShoppingCategory({
    required this.name,
    required this.tag,
    required this.items,
    this.isExpanded = false,
  });
}
