import 'package:flutter/material.dart';
import 'store_price.dart';
import 'purchase_record.dart';

class ShoppingItem {
  final String name;
  final String categoryName;
  final String categoryTag;
  final Color categoryColor;
  final IconData categoryIcon;
  final int quantity;
  final String unit;
  final int estimatedPrice;
  final bool isHighPriority;
  final String? note;
  final List<StorePrice> storePrices;
  final List<PurchaseRecord> purchases;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.categoryName,
    required this.categoryTag,
    required this.categoryColor,
    this.categoryIcon = Icons.category_outlined,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.isHighPriority = false,
    this.note,
    List<StorePrice>? storePrices,
    List<PurchaseRecord>? purchases,
    this.isChecked = false,
  }) : storePrices = storePrices ?? [],
       purchases = purchases ?? [];
}
