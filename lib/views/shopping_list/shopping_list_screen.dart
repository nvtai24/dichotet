import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_Category> _categories = [
    _Category(
      name: 'Đặc sản Tết',
      icon: Icons.card_giftcard_outlined,
      iconColor: AppColors.primary,
      isExpanded: true,
      items: [
        _Item(name: 'Bánh Chưng', qty: '4', price: 120000, isChecked: true),
        _Item(name: 'Phong bao lì xì', qty: '2', unit: 'bộ', price: 55000, isHighPriority: true),
        _Item(name: 'Mâm ngũ quả', qty: '1', unit: 'mâm', price: 250000, isChecked: true),
        _Item(name: 'Mứt Tết', qty: '3', unit: 'hộp', price: 80000),
        _Item(name: 'Bánh Tét', qty: '2', price: 70000),
      ],
    ),
    _Category(
      name: 'Thực phẩm & Đồ uống',
      icon: Icons.restaurant_outlined,
      iconColor: const Color(0xFF43A047),
      items: [
        _Item(name: 'Thịt heo', qty: '3', unit: 'kg', price: 180000),
        _Item(name: 'Tôm tươi', qty: '1', unit: 'kg', price: 250000),
        _Item(name: 'Rau củ các loại', qty: '2', unit: 'kg', price: 60000),
        _Item(name: 'Nước ngọt', qty: '2', unit: 'thùng', price: 140000),
        _Item(name: 'Bia', qty: '1', unit: 'thùng', price: 180000),
        _Item(name: 'Trứng gà', qty: '30', unit: 'quả', price: 90000),
      ],
    ),
    _Category(
      name: 'Trang trí - Hoa',
      icon: Icons.local_florist_outlined,
      iconColor: const Color(0xFFE91E8A),
      items: [
        _Item(name: 'Hoa mai', qty: '1', unit: 'cành', price: 350000, isChecked: true),
        _Item(name: 'Hoa đào', qty: '1', unit: 'chậu', price: 300000, isChecked: true),
        _Item(name: 'Dây đèn LED', qty: '2', unit: 'cuộn', price: 85000),
        _Item(name: 'Câu đối Tết', qty: '1', unit: 'bộ', price: 45000),
      ],
    ),
    _Category(
      name: 'Quà cáp',
      icon: Icons.redeem_outlined,
      iconColor: const Color(0xFFFF6F00),
      items: [
        _Item(name: 'Giỏ quà Tết', qty: '3', unit: 'giỏ', price: 450000, isChecked: true),
        _Item(name: 'Trà Oolong hộp', qty: '2', unit: 'hộp', price: 180000),
        _Item(name: 'Rượu vang', qty: '1', unit: 'chai', price: 320000),
        _Item(name: 'Kẹo socola', qty: '2', unit: 'hộp', price: 120000),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<({_Item item, String categoryName})> _searchResults() {
    final q = _searchQuery.toLowerCase();
    return [
      for (final cat in _categories)
        for (final item in cat.items)
          if (item.name.toLowerCase().contains(q))
            (item: item, categoryName: cat.name),
    ];
  }

  Widget _buildCategoryList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CategorySection(
        category: _categories[i],
        onToggleExpand: () =>
            setState(() => _categories[i].isExpanded = !_categories[i].isExpanded),
        onToggleItem: (itemIndex) => setState(() {
          _categories[i].items[itemIndex].isChecked =
              !_categories[i].items[itemIndex].isChecked;
        }),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults();
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
            SizedBox(height: 8),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        final globalIndex = _categories
            .firstWhere((c) => c.name == r.categoryName)
            .items
            .indexOf(r.item);
        final catIndex =
            _categories.indexWhere((c) => c.name == r.categoryName);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _ItemTile(
            item: r.item,
            isLast: true,
            categoryLabel: r.categoryName,
            onToggle: () => setState(() {
              _categories[catIndex].items[globalIndex].isChecked =
                  !_categories[catIndex].items[globalIndex].isChecked;
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món đồ...',
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
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Search results or category list
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
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
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.tune_outlined,
                size: 22, color: AppColors.primary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

// ─── Category Section ─────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final _Category category;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onToggleItem;

  const _CategorySection({
    required this.category,
    required this.onToggleExpand,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    final checkedCount = category.items.where((i) => i.isChecked).length;
    final totalCount = category.items.length;

    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: category.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(category.icon,
                        size: 18, color: category.iconColor),
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
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: checkedCount == totalCount
                          ? AppColors.primary.withValues(alpha: 0.12)
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
          if (category.isExpanded && category.items.isNotEmpty) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            ...category.items.asMap().entries.map((entry) => _ItemTile(
                  item: entry.value,
                  isLast: entry.key == category.items.length - 1,
                  onToggle: () => onToggleItem(entry.key),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Item Tile ────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  final _Item item;
  final bool isLast;
  final VoidCallback onToggle;
  final String? categoryLabel;

  const _ItemTile({
    required this.item,
    required this.isLast,
    required this.onToggle,
    this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 12, 14, isLast ? 14 : 12),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: item.isChecked
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
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
                    categoryLabel != null
                        ? '$categoryLabel · Qty: ${item.qty}${item.unit.isNotEmpty ? ' ${item.unit}' : ''}'
                        : 'Qty: ${item.qty}${item.unit.isNotEmpty ? ' ${item.unit}' : ''}',
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
                  _formatPrice(item.price),
                  style: TextStyle(
                    fontSize: 13,
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
                if (item.isHighPriority) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'HIGH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        letterSpacing: 0.5,
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

// ─── Data Models ──────────────────────────────────────────────────────────────

class _Category {
  final String name;
  final IconData icon;
  final Color iconColor;
  final List<_Item> items;
  bool isExpanded;

  _Category({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.items,
    this.isExpanded = false,
  });
}

class _Item {
  final String name;
  final String qty;
  final String unit;
  final int price;
  final bool isHighPriority;
  bool isChecked;

  _Item({
    required this.name,
    required this.qty,
    this.unit = '',
    required this.price,
    this.isHighPriority = false,
    this.isChecked = false,
  });
}
