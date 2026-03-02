import 'package:flutter/material.dart';

enum StoreType { market, supermarket, vendor }

class StorePrice {
  final String storeName;
  final StoreType type;
  final int pricePerUnit;
  final String lastUpdated;

  StorePrice({
    required this.storeName,
    required this.type,
    required this.pricePerUnit,
    required this.lastUpdated,
  });
}

class ShoppingItem {
  final String name;
  final String categoryName;
  final String categoryTag;
  final Color categoryColor;
  final int quantity;
  final String unit;
  final int estimatedPrice;
  final bool isHighPriority;
  final String? note;
  final String? imageUrl;
  final List<StorePrice> storePrices;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.categoryName,
    required this.categoryTag,
    required this.categoryColor,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.isHighPriority = false,
    this.note,
    this.imageUrl,
    List<StorePrice>? storePrices,
    this.isChecked = false,
  }) : storePrices = storePrices ?? [];
}

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
