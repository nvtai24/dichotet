import 'package:flutter/material.dart';

enum StoreType { market, supermarket, vendor }

class ShoppingSession {
  final String id;
  final String userId;
  final String name;
  final double budget;
  final bool isActive;
  final DateTime createdAt;

  ShoppingSession({
    required this.id,
    required this.userId,
    required this.name,
    required this.budget,
    this.isActive = true,
    required this.createdAt,
  });
}

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

class PurchaseRecord {
  final int? id;
  final int quantity;
  final int pricePerUnit;
  final DateTime purchasedAt;
  final String? locationName;

  PurchaseRecord({
    this.id,
    required this.quantity,
    required this.pricePerUnit,
    required this.purchasedAt,
    this.locationName,
  });
}

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
