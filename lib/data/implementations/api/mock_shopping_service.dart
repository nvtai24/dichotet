import 'package:flutter/material.dart';
import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_shopping_service.dart';
import '../../../core/constants/app_colors.dart';

/// Mock implementation – trả dữ liệu giả.
/// Khi có API Supabase, tạo class SupabaseShoppingService implement
/// IShoppingService, gọi supabase.from('shopping_items')... rồi
/// dùng Mapper để chuyển JSON → model.
class MockShoppingService implements IShoppingService {
  // Simulated in-memory data
  late final List<ShoppingCategory> _categories;

  MockShoppingService() {
    _categories = _buildMockCategories();
  }

  @override
  Future<List<ShoppingCategory>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories;
  }

  @override
  Future<List<String>> getCategoryNames() async {
    return [
      'Thực phẩm',
      'Bánh kẹo - Mứt',
      'Trang trí - Hoa',
      'Quà cáp',
      'Đồ uống',
      'Khác',
    ];
  }

  @override
  Future<List<String>> getStoreNames() async {
    return ['Chợ Bến Thành', 'Lotte Mart', 'Vinmart', 'Chợ địa phương'];
  }

  @override
  Future<void> addItem(ShoppingItem item, String categoryName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final cat = _categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => _categories.first,
    );
    cat.items.add(item);
  }

  @override
  Future<void> updateItemPurchaseStatus(
    ShoppingItem item, {
    required bool isPurchased,
    int? actualQuantity,
    int? actualPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    item.isChecked = isPurchased;
    item.actualQuantity = actualQuantity;
    item.actualPrice = actualPrice;
  }

  @override
  Future<void> addStorePrice(ShoppingItem item, StorePrice storePrice) async {
    await Future.delayed(const Duration(milliseconds: 200));
    item.storePrices.add(storePrice);
  }

  // ─── Mock Data ──────────────────────────────────────────────────────

  List<ShoppingCategory> _buildMockCategories() {
    return [
      ShoppingCategory(
        name: 'Đặc sản Tết',
        color: AppColors.primary,
        tag: 'TRUYỀN THỐNG',
        icon: Icons.card_giftcard_outlined,
        isExpanded: true,
        items: [
          ShoppingItem(
            name: 'Bánh Chưng',
            categoryName: 'Đặc sản Tết',
            categoryTag: 'TRUYỀN THỐNG',
            categoryColor: AppColors.primary,
            quantity: 4,
            unit: 'cái',
            estimatedPrice: 120000,
            isChecked: true,
            note:
                'Mua ở chợ Bến Thành, chọn loại hút chân không để giữ được lâu hơn.',
            storePrices: [
              StorePrice(
                storeName: 'Chợ Bến Thành',
                type: StoreType.market,
                pricePerUnit: 150000,
                lastUpdated: '2 ngày trước',
              ),
              StorePrice(
                storeName: 'Co.op Mart',
                type: StoreType.supermarket,
                pricePerUnit: 135000,
                lastUpdated: '5 ngày trước',
              ),
              StorePrice(
                storeName: 'Chợ địa phương',
                type: StoreType.vendor,
                pricePerUnit: 120000,
                lastUpdated: '1 tuần trước',
              ),
            ],
          ),
          ShoppingItem(
            name: 'Phong bao lì xì',
            categoryName: 'Đặc sản Tết',
            categoryTag: 'TRUYỀN THỐNG',
            categoryColor: AppColors.primary,
            quantity: 2,
            unit: 'bộ',
            estimatedPrice: 55000,
            isHighPriority: true,
            note: 'Chọn loại có in hình rồng vàng.',
          ),
          ShoppingItem(
            name: 'Mâm ngũ quả',
            categoryName: 'Đặc sản Tết',
            categoryTag: 'TRUYỀN THỐNG',
            categoryColor: AppColors.primary,
            quantity: 1,
            unit: 'mâm',
            estimatedPrice: 250000,
            isChecked: true,
            storePrices: [
              StorePrice(
                storeName: 'Chợ Bến Thành',
                type: StoreType.market,
                pricePerUnit: 260000,
                lastUpdated: '3 ngày trước',
              ),
            ],
          ),
          ShoppingItem(
            name: 'Mứt Tết',
            categoryName: 'Đặc sản Tết',
            categoryTag: 'TRUYỀN THỐNG',
            categoryColor: AppColors.primary,
            quantity: 3,
            unit: 'hộp',
            estimatedPrice: 80000,
          ),
          ShoppingItem(
            name: 'Bánh Tét',
            categoryName: 'Đặc sản Tết',
            categoryTag: 'TRUYỀN THỐNG',
            categoryColor: AppColors.primary,
            quantity: 2,
            unit: 'cái',
            estimatedPrice: 70000,
          ),
        ],
      ),
      ShoppingCategory(
        name: 'Thực phẩm & Đồ uống',
        color: const Color(0xFF43A047),
        tag: 'THỰC PHẨM',
        icon: Icons.restaurant_outlined,
        items: [
          ShoppingItem(
            name: 'Thịt Heo',
            categoryName: 'Thực phẩm & Đồ uống',
            categoryTag: 'THỰC PHẨM',
            categoryColor: const Color(0xFF43A047),
            quantity: 3,
            unit: 'kg',
            estimatedPrice: 180000,
            storePrices: [
              StorePrice(
                storeName: 'Chợ Bến Thành',
                type: StoreType.market,
                pricePerUnit: 185000,
                lastUpdated: '1 ngày trước',
              ),
            ],
          ),
          ShoppingItem(
            name: 'Tôm tươi',
            categoryName: 'Thực phẩm & Đồ uống',
            categoryTag: 'THỰC PHẨM',
            categoryColor: const Color(0xFF43A047),
            quantity: 1,
            unit: 'kg',
            estimatedPrice: 250000,
            isHighPriority: true,
          ),
          ShoppingItem(
            name: 'Nước ngọt',
            categoryName: 'Thực phẩm & Đồ uống',
            categoryTag: 'THỰC PHẨM',
            categoryColor: const Color(0xFF43A047),
            quantity: 2,
            unit: 'thùng',
            estimatedPrice: 140000,
          ),
          ShoppingItem(
            name: 'Bia',
            categoryName: 'Thực phẩm & Đồ uống',
            categoryTag: 'THỰC PHẨM',
            categoryColor: const Color(0xFF43A047),
            quantity: 1,
            unit: 'thùng',
            estimatedPrice: 180000,
          ),
        ],
      ),
      ShoppingCategory(
        name: 'Trang trí - Hoa',
        color: const Color(0xFFE91E8A),
        tag: 'TRANG TRÍ',
        icon: Icons.local_florist_outlined,
        items: [
          ShoppingItem(
            name: 'Hoa mai',
            categoryName: 'Trang trí - Hoa',
            categoryTag: 'TRANG TRÍ',
            categoryColor: const Color(0xFFE91E8A),
            quantity: 1,
            unit: 'cành',
            estimatedPrice: 350000,
            isChecked: true,
          ),
          ShoppingItem(
            name: 'Đèn lồng đỏ',
            categoryName: 'Trang trí - Hoa',
            categoryTag: 'TRANG TRÍ',
            categoryColor: const Color(0xFFE91E8A),
            quantity: 2,
            unit: 'bộ',
            estimatedPrice: 180000,
            storePrices: [
              StorePrice(
                storeName: 'Chợ Bến Thành',
                type: StoreType.market,
                pricePerUnit: 200000,
                lastUpdated: '3 ngày trước',
              ),
            ],
          ),
          ShoppingItem(
            name: 'Câu đối Tết',
            categoryName: 'Trang trí - Hoa',
            categoryTag: 'TRANG TRÍ',
            categoryColor: const Color(0xFFE91E8A),
            quantity: 1,
            unit: 'bộ',
            estimatedPrice: 45000,
          ),
        ],
      ),
      ShoppingCategory(
        name: 'Quà cáp',
        color: const Color(0xFFFF6F00),
        tag: 'QUÀ CÁP',
        icon: Icons.redeem_outlined,
        items: [
          ShoppingItem(
            name: 'Giỏ quà Tết',
            categoryName: 'Quà cáp',
            categoryTag: 'QUÀ CÁP',
            categoryColor: const Color(0xFFFF6F00),
            quantity: 3,
            unit: 'giỏ',
            estimatedPrice: 450000,
            isChecked: true,
          ),
          ShoppingItem(
            name: 'Rượu vang',
            categoryName: 'Quà cáp',
            categoryTag: 'QUÀ CÁP',
            categoryColor: const Color(0xFFFF6F00),
            quantity: 1,
            unit: 'chai',
            estimatedPrice: 320000,
            storePrices: [
              StorePrice(
                storeName: 'Vinmart',
                type: StoreType.supermarket,
                pricePerUnit: 350000,
                lastUpdated: '4 ngày trước',
              ),
            ],
          ),
          ShoppingItem(
            name: 'Kẹo socola',
            categoryName: 'Quà cáp',
            categoryTag: 'QUÀ CÁP',
            categoryColor: const Color(0xFFFF6F00),
            quantity: 2,
            unit: 'hộp',
            estimatedPrice: 120000,
            isHighPriority: true,
          ),
          ShoppingItem(
            name: 'Trà Oolong hộp',
            categoryName: 'Quà cáp',
            categoryTag: 'QUÀ CÁP',
            categoryColor: const Color(0xFFFF6F00),
            quantity: 2,
            unit: 'hộp',
            estimatedPrice: 180000,
          ),
        ],
      ),
    ];
  }
}
