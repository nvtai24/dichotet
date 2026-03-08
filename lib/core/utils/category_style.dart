import 'package:flutter/material.dart';

/// Map tên icon (lưu trong DB) sang Flutter IconData.
/// Thêm entry mới ở đây khi cần hỗ trợ thêm icon.
class CategoryStyle {
  CategoryStyle._();

  static const Map<String, IconData> _iconMap = {
    'card_giftcard': Icons.card_giftcard_outlined,
    'restaurant': Icons.restaurant_outlined,
    'local_florist': Icons.local_florist_outlined,
    'redeem': Icons.redeem_outlined,
    'local_cafe': Icons.local_cafe_outlined,
    'category': Icons.category_outlined,
    'shopping_bag': Icons.shopping_bag_outlined,
    'shopping_cart': Icons.shopping_cart_outlined,
    'fastfood': Icons.fastfood_outlined,
    'cake': Icons.cake_outlined,
    'local_bar': Icons.local_bar_outlined,
    'icecream': Icons.icecream_outlined,
    'pets': Icons.pets_outlined,
    'checkroom': Icons.checkroom_outlined,
    'devices': Icons.devices_outlined,
    'cleaning_services': Icons.cleaning_services_outlined,
    'home': Icons.home_outlined,
    'build': Icons.build_outlined,
    'spa': Icons.spa_outlined,
    'toys': Icons.toys_outlined,
    'sports_esports': Icons.sports_esports_outlined,
    'medication': Icons.medication_outlined,
  };

  static IconData iconFrom(String? name) {
    if (name == null || name.isEmpty) return Icons.category_outlined;
    return _iconMap[name] ?? Icons.category_outlined;
  }

  static Color colorFrom(String? hex) {
    if (hex == null || hex.length < 7) return const Color(0xFFC62828);
    try {
      return Color(int.parse('FF${hex.substring(1)}', radix: 16));
    } catch (_) {
      return const Color(0xFFC62828);
    }
  }

  /// Danh sách tên icon có sẵn (dùng cho UI chọn icon nếu cần).
  static List<String> get availableIconNames => _iconMap.keys.toList();
}
