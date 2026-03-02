import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'shopping_item_model.dart';
import 'item_detail_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _activeTab = 0; // 0: All, 1: Pending, 2: Purchased

  final List<ShoppingCategory> _categories = [
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
          note: 'Mua ở chợ Bến Thành, chọn loại hút chân không để giữ được lâu hơn.',
          storePrices: [
            StorePrice(storeName: 'Chợ Bến Thành', type: StoreType.market, pricePerUnit: 150000, lastUpdated: '2 ngày trước'),
            StorePrice(storeName: 'Co.op Mart', type: StoreType.supermarket, pricePerUnit: 135000, lastUpdated: '5 ngày trước'),
            StorePrice(storeName: 'Chợ địa phương', type: StoreType.vendor, pricePerUnit: 120000, lastUpdated: '1 tuần trước'),
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
            StorePrice(storeName: 'Chợ Bến Thành', type: StoreType.market, pricePerUnit: 260000, lastUpdated: '3 ngày trước'),
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
            StorePrice(storeName: 'Chợ Bến Thành', type: StoreType.market, pricePerUnit: 185000, lastUpdated: '1 ngày trước'),
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
            StorePrice(storeName: 'Chợ Bến Thành', type: StoreType.market, pricePerUnit: 200000, lastUpdated: '3 ngày trước'),
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
            StorePrice(storeName: 'Vinmart', type: StoreType.supermarket, pricePerUnit: 350000, lastUpdated: '4 ngày trước'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _itemMatchesTab(ShoppingItem item) {
    if (_activeTab == 1) return !item.isChecked;
    if (_activeTab == 2) return item.isChecked;
    return true;
  }

  bool _itemMatchesSearch(ShoppingItem item) {
    if (_searchQuery.isEmpty) return true;
    return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  List<ShoppingItem> _visibleItems(ShoppingCategory cat) {
    return cat.items
        .where((i) => _itemMatchesTab(i) && _itemMatchesSearch(i))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final visible = _visibleItems(cat);
                if (visible.isEmpty) return const SizedBox.shrink();
                return _CategoryAccordion(
                  category: cat,
                  visibleItems: visible,
                  onToggleExpand: () =>
                      setState(() => cat.isExpanded = !cat.isExpanded),
                  onToggleCheck: (item) =>
                      setState(() => item.isChecked = !item.isChecked),
                  onTapItem: (item) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ItemDetailScreen(item: item)),
                  ).then((_) => setState(() {})),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leadingWidth: 48,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Icon(Icons.calendar_today_outlined,
            size: 20, color: AppColors.primary),
      ),
      title: const Text(
        'Tet Shopping List',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.tune_outlined,
                size: 22, color: AppColors.primary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search items...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.primary.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['All', 'Pending', 'Purchased'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = _activeTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: labels[i].length * 7.5,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Category Accordion ───────────────────────────────────────────────────────

class _CategoryAccordion extends StatelessWidget {
  final ShoppingCategory category;
  final List<ShoppingItem> visibleItems;
  final VoidCallback onToggleExpand;
  final ValueChanged<ShoppingItem> onToggleCheck;
  final ValueChanged<ShoppingItem> onTapItem;

  const _CategoryAccordion({
    required this.category,
    required this.visibleItems,
    required this.onToggleExpand,
    required this.onToggleCheck,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final checkedCount = visibleItems.where((i) => i.isChecked).length;
    final totalCount = visibleItems.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: onToggleExpand,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(category.icon,
                          size: 18, color: category.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Checked/total badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: checkedCount == totalCount
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$checkedCount/$totalCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: checkedCount == totalCount
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: category.isExpanded ? 0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // Items
            if (category.isExpanded) ...[
              Divider(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.5)),
              ...visibleItems.asMap().entries.map((e) {
                final item = e.value;
                final isLast = e.key == visibleItems.length - 1;
                return Column(
                  children: [
                    _ItemTile(
                      item: item,
                      isLast: isLast,
                      onToggleCheck: () => onToggleCheck(item),
                      onTap: () => onTapItem(item),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 14,
                        color: AppColors.divider.withValues(alpha: 0.4),
                      ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Item Tile ────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  final ShoppingItem item;
  final bool isLast;
  final VoidCallback onToggleCheck;
  final VoidCallback onTap;

  const _ItemTile({
    required this.item,
    required this.isLast,
    required this.onToggleCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceColor =
        item.isHighPriority && !item.isChecked ? AppColors.error : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 12, 14, isLast ? 14 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circle checkbox
            GestureDetector(
              onTap: onToggleCheck,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isChecked ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: item.isChecked
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: item.isChecked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Name + qty
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.isChecked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: ${item.quantity} ${item.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Price + HIGH badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(item.estimatedPrice),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.isChecked ? AppColors.textSecondary : priceColor,
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
                if (item.isHighPriority && !item.isChecked) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'HIGH',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }
}
