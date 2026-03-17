import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';
import 'edit_item_screen.dart';
import 'edit_purchases_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final ShoppingItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ShoppingItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  ShoppingItem? _findItemByName(String name) {
    final vm = context.read<ShoppingListViewModel>();
    for (final cat in vm.categories) {
      for (final item in cat.items) {
        if (item.name == name) return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi Tiết Sản Phẩm',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditItemScreen(item: _item),
                  ),
                );
                if (result != null && mounted) {
                  final updated = _findItemByName(result);
                  if (updated != null) {
                    setState(() => _item = updated);
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            AppNetworkImage(
              url: _item.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + category badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _item.categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _item.categoryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _item.categoryTag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _item.categoryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  _buildStatsRow(),
                  const SizedBox(height: 16),

                  // Purchase info card (if has any purchases)
                  if (_item.purchases.isNotEmpty) ...[
                    _buildPurchaseInfoCard(),
                    const SizedBox(height: 16),
                  ],

                  // Notes
                  if (_item.note != null && _item.note!.isNotEmpty) ...[
                    _buildNotesCard(),
                    const SizedBox(height: 16),
                  ],

                  // Stores section
                  _buildStoresSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _item.isChecked
          ? OutlinedButton.icon(
              onPressed: _showPurchaseSheet,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text(
                'Thêm lần mua mới',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _showPurchaseSheet,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text(
                'Thêm thông tin đã mua',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
    );
  }

  Widget _buildPurchaseInfoCard() {
    final purchases = _item.purchases;
    final totalSpent = purchases.fold<int>(
      0,
      (sum, p) => sum + p.quantity * p.pricePerUnit,
    );
    final totalQty = purchases.fold<int>(0, (sum, p) => sum + p.quantity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Color(0xFF43A047),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lịch sử mua hàng (${purchases.length} lần)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF43A047),
                  ),
                ),
              ),
              if (purchases.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPurchasesScreen(item: _item),
                      ),
                    );
                    if (result == true && mounted) {
                      final updated = _findItemByName(_item.name);
                      if (updated != null) {
                        setState(() => _item = updated);
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: Color(0xFF43A047),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Sửa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (purchases.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Chưa có thông tin mua hàng',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            )
          else ...[
            const SizedBox(height: 12),
            // Summary row
            Row(
              children: [
                Expanded(
                  child: _PurchaseStatBox(
                    label: 'Tổng số lượng',
                    value: '$totalQty ${_item.unit}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PurchaseStatBox(
                    label: 'Tổng chi',
                    value: _formatPriceShort(totalSpent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Individual purchase records
            ...purchases.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              final date = p.purchasedAt;
              final dateStr =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
                  '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF43A047).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF43A047),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.quantity} ${_item.unit} × ${_formatPriceShort(p.pricePerUnit)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (p.locationName != null &&
                                p.locationName!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      p.locationName!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatPriceShort(p.quantity * p.pricePerUnit),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF43A047),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatBox(
          label: 'Số lượng',
          value: '${_item.quantity}',
          sub: _item.unit,
        ),
        const SizedBox(width: 10),
        _StatBox(
          label: 'Giá ước tính',
          value: _formatPriceShort(_item.estimatedPrice),
          sub: '/${_item.unit}',
        ),
        const SizedBox(width: 10),
        _StatBox(label: 'Đơn vị', value: _item.unit, sub: ''),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _item.note!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cửa hàng & Giá tại chỗ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _showAddPriceSheet,
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 15,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Thêm giá',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _item.storePrices.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
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
                child: const Center(
                  child: Text(
                    'Chưa có giá cửa hàng nào.\nNhấn "Thêm giá" để thêm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              )
            : Container(
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
                child: Column(
                  children: _item.storePrices.asMap().entries.map((e) {
                    final isLast = e.key == _item.storePrices.length - 1;
                    return Column(
                      children: [
                        _StorePriceRow(store: e.value, unit: _item.unit),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 48,
                            endIndent: 14,
                            color: AppColors.divider.withValues(alpha: 0.5),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  String _formatPriceShort(int price) {
    if (price >= 1000000) {
      final m = price / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M ₫';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k ₫';
    }
    return '$price ₫';
  }

  void _showAddPriceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddPriceSheet(
        onAdd: (store) => setState(() => _item.storePrices.add(store)),
      ),
    );
  }

  void _showPurchaseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConfirmPurchaseSheet(
        item: _item,
        onConfirm: (qty, price, location) async {
          final vm = context.read<ShoppingListViewModel>();
          await vm.confirmPurchase(
            _item,
            quantity: qty,
            price: price,
            locationName: location,
          );
          await vm.forceRefresh();
          if (!mounted) return;
          final updated = _findItemByName(_item.name);
          if (updated != null) {
            setState(() => _item = updated);
          } else {
            setState(() {});
          }
        },
      ),
    );
  }
}

// ─── Stat Box ─────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _StatBox({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Store Price Row ──────────────────────────────────────────────────────────

class _StorePriceRow extends StatelessWidget {
  final StorePrice store;
  final String unit;

  const _StorePriceRow({required this.store, required this.unit});

  IconData get _icon => switch (store.type) {
    StoreType.market => Icons.place_outlined,
    StoreType.supermarket => Icons.shopping_cart_outlined,
    StoreType.vendor => Icons.store_outlined,
  };

  Color get _iconColor => switch (store.type) {
    StoreType.market => AppColors.primary,
    StoreType.supermarket => const Color(0xFF43A047),
    StoreType.vendor => const Color(0xFFFF6F00),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, size: 18, color: _iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Cập nhật: ${store.lastUpdated}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(store.pricePerUnit),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'trên $unit',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
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

// ─── Add Price Sheet ──────────────────────────────────────────────────────────

class _AddPriceSheet extends StatefulWidget {
  final ValueChanged<StorePrice> onAdd;
  const _AddPriceSheet({required this.onAdd});

  @override
  State<_AddPriceSheet> createState() => _AddPriceSheetState();
}

class _AddPriceSheetState extends State<_AddPriceSheet> {
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();
  StoreType _storeType = StoreType.market;

  @override
  void dispose() {
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (_storeController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      return;
    }
    widget.onAdd(
      StorePrice(
        storeName: _storeController.text.trim(),
        type: _storeType,
        pricePerUnit: int.tryParse(_priceController.text.trim()) ?? 0,
        lastUpdated: 'Vừa xong',
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final storeTypes = [
      (StoreType.market, 'Chợ'),
      (StoreType.supermarket, 'Siêu thị'),
      (StoreType.vendor, 'Quầy hàng'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thêm giá cửa hàng',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          // Store type chips
          Row(
            children: storeTypes.map((t) {
              final isSelected = t.$1 == _storeType;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _storeType = t.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        t.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storeController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Tên cửa hàng',
              hintText: 'Ví dụ: Chợ Bến Thành',
              prefixIcon: Icon(Icons.storefront_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Giá / đơn vị (VND)',
              hintText: '0',
              prefixIcon: Icon(Icons.sell_outlined, size: 20),
              suffixText: '₫',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onAdd,
              child: const Text(
                'Thêm giá',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Purchase Stat Box ────────────────────────────────────────────────────────

class _PurchaseStatBox extends StatelessWidget {
  final String label;
  final String value;

  const _PurchaseStatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF43A047)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Purchase Sheet ───────────────────────────────────────────────────

class _ConfirmPurchaseSheet extends StatefulWidget {
  final ShoppingItem item;
  final Future<void> Function(int quantity, int price, String? locationName)
  onConfirm;

  const _ConfirmPurchaseSheet({required this.item, required this.onConfirm});

  @override
  State<_ConfirmPurchaseSheet> createState() => _ConfirmPurchaseSheetState();
}

class _ConfirmPurchaseSheetState extends State<_ConfirmPurchaseSheet> {
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  late final TextEditingController _newLocationController;
  String? _selectedLocation;
  bool _isAddingNew = false;

  List<String> get _locationNames =>
      widget.item.storePrices.map((s) => s.storeName).toSet().toList();

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    _priceController = TextEditingController();
    _newLocationController = TextEditingController();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _newLocationController.dispose();
    super.dispose();
  }

  void _onConfirm() async {
    final qty = int.tryParse(_qtyController.text.trim());
    final price = int.tryParse(_priceController.text.trim());
    if (qty == null || qty <= 0 || price == null || price < 0) return;

    final location = _isAddingNew
        ? _newLocationController.text.trim()
        : _selectedLocation;

    if (location == null || location.isEmpty) return;

    await widget.onConfirm(qty, price, location);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin đã mua',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Location dropdown
          if (!_isAddingNew)
            DropdownButtonFormField<String>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Nơi mua',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              ),
              items: [
                ..._locationNames.map(
                  (name) => DropdownMenuItem(value: name, child: Text(name)),
                ),
                const DropdownMenuItem(
                  value: '__add_new__',
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Thêm địa điểm mới',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == '__add_new__') {
                  setState(() {
                    _isAddingNew = true;
                    _selectedLocation = null;
                  });
                } else {
                  setState(() => _selectedLocation = value);
                }
              },
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Tên địa điểm mới',
                      prefixIcon: Icon(
                        Icons.add_location_alt_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (_locationNames.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() {
                      _isAddingNew = false;
                      _newLocationController.clear();
                    }),
                  ),
              ],
            ),
          const SizedBox(height: 12),

          // Quantity input
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Số lượng đã mua',
              hintText: 'Ví dụ: 2',
              prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
              suffixText: widget.item.unit,
            ),
          ),
          const SizedBox(height: 12),

          // Price input
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Số tiền đã dùng (VND)',
              hintText: '0',
              prefixIcon: Icon(Icons.payments_outlined, size: 20),
              suffixText: '₫',
            ),
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onConfirm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
