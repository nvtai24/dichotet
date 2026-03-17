import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';
import 'edit_item_screen.dart';
import 'edit_purchases_screen.dart';
import '../location/location_picker_screen.dart';

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
      backgroundColor: AppColors.background,
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
            GestureDetector(
              onTap: (_item.imageUrl != null && _item.imageUrl!.isNotEmpty)
                  ? () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          barrierColor: Colors.black,
                          pageBuilder: (_, _, _) => _FullScreenImagePage(
                            url: _item.imageUrl!,
                            heroTag: 'item_image_${_item.name}',
                          ),
                          transitionsBuilder: (_, anim, _, child) =>
                              FadeTransition(opacity: anim, child: child),
                        ),
                      )
                  : null,
              child: Hero(
                tag: 'item_image_${_item.name}',
                child: AppNetworkImage(
                  url: _item.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
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
        if (_item.storePrices.length >= 2) ...[
          _PriceComparisonCard(
            storePrices: _item.storePrices,
            unit: _item.unit,
          ),
          const SizedBox(height: 12),
        ],
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
        onAdd: (store) {
            final vm = context.read<ShoppingListViewModel>();
            vm.addStorePrice(_item, store);
            setState(() => _item.storePrices.add(store));
          },
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
        onConfirm: (qty, price, location, lat, lon) async {
          final vm = context.read<ShoppingListViewModel>();
          await vm.confirmPurchase(
            _item,
            quantity: qty,
            price: price,
            locationName: location,
            locationLat: lat,
            locationLon: lon,
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

  IconData get _icon => Icons.place_outlined;

  Color get _iconColor => AppColors.primary;

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

// ─── Price Comparison Card ────────────────────────────────────────────────────

class _PriceComparisonCard extends StatelessWidget {
  final List<StorePrice> storePrices;
  final String unit;

  const _PriceComparisonCard({
    required this.storePrices,
    required this.unit,
  });

  String _fmt(int price) {
    if (price >= 1000000) {
      final m = price / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M ₫';
    }
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k ₫';
    return '$price ₫';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...storePrices]
      ..sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
    final cheapest = sorted.first;
    final maxPrice = sorted.last.pricePerUnit;
    final saving = maxPrice - cheapest.pricePerUnit;
    const green = Color(0xFF2E7D32);
    const greenLight = Color(0xFF43A047);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            greenLight.withValues(alpha: 0.08),
            greenLight.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenLight.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: greenLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  size: 15,
                  color: greenLight,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'So sánh giá',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: green,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: greenLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${sorted.length} cửa hàng',
                  style: const TextStyle(
                    fontSize: 11,
                    color: green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ranking rows
          ...sorted.asMap().entries.map((e) {
            final i = e.key;
            final store = e.value;
            final isCheapest = i == 0;
            final ratio = maxPrice == 0 ? 1.0 : store.pricePerUnit / maxPrice;
            const medals = ['🥇', '🥈', '🥉'];
            final medal = i < 3 ? medals[i] : '${i + 1}.';

            return Padding(
              padding: EdgeInsets.only(bottom: i < sorted.length - 1 ? 10 : 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(medal, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: Text(
                      store.storeName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isCheapest ? FontWeight.w700 : FontWeight.w500,
                        color: isCheapest ? green : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: LayoutBuilder(
                      builder: (_, constraints) => Stack(
                        children: [
                          Container(
                            height: 6,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            height: 6,
                            width: constraints.maxWidth * ratio,
                            decoration: BoxDecoration(
                              color: isCheapest
                                  ? greenLight
                                  : const Color(0xFFEF5350)
                                      .withValues(alpha: 0.55 + 0.45 * ratio),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _fmt(store.pricePerUnit),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isCheapest ? FontWeight.w700 : FontWeight.w500,
                      color: isCheapest ? green : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Savings tip
          if (saving > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: greenLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Mua ở ${cheapest.storeName} tiết kiệm ${_fmt(saving)}/$unit so với nơi đắt nhất',
                      style: const TextStyle(
                        fontSize: 12,
                        color: green,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
  double? _lat;
  double? _lon;

  @override
  void dispose() {
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          storeName: _storeController.text.trim().isNotEmpty
              ? _storeController.text.trim()
              : null,
          initialLocation:
              (_lat != null && _lon != null) ? LatLng(_lat!, _lon!) : null,
        ),
      ),
    );
    if (result == null) {
      setState(() { _lat = null; _lon = null; });
    } else {
      setState(() { _lat = result.latitude; _lon = result.longitude; });
    }
  }

  void _onAdd() {
    if (_storeController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      return;
    }
    widget.onAdd(
      StorePrice(
        storeName: _storeController.text.trim(),
        pricePerUnit: int.tryParse(_priceController.text.trim()) ?? 0,
        lastUpdated: 'Vừa xong',
        lat: _lat,
        lon: _lon,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: (_lat != null)
                    ? AppColors.primary.withValues(alpha: 0.07)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (_lat != null)
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _lat != null
                        ? Icons.location_on_rounded
                        : Icons.add_location_alt_outlined,
                    size: 18,
                    color: _lat != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lat != null
                          ? 'Đã ghim: ${_lat!.toStringAsFixed(4)}, ${_lon!.toStringAsFixed(4)}'
                          : 'Ghim vị trí trên bản đồ (tùy chọn)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _lat != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: _lat != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_lat != null)
                    GestureDetector(
                      onTap: () => setState(() { _lat = null; _lon = null; }),
                      child: Icon(Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary.withValues(alpha: 0.6)),
                    ),
                ],
              ),
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
  final Future<void> Function(
      int quantity, int price, String? locationName,
      double? lat, double? lon) onConfirm;

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
  double? _newLat;
  double? _newLon;

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

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          storeName: _newLocationController.text.trim().isNotEmpty
              ? _newLocationController.text.trim()
              : null,
          initialLocation: (_newLat != null && _newLon != null)
              ? LatLng(_newLat!, _newLon!)
              : null,
        ),
      ),
    );
    if (result == null) {
      setState(() { _newLat = null; _newLon = null; });
    } else {
      setState(() { _newLat = result.latitude; _newLon = result.longitude; });
    }
  }

  void _onConfirm() async {
    final qty = int.tryParse(_qtyController.text.trim());
    final price = int.tryParse(_priceController.text.trim());
    if (qty == null || qty <= 0 || price == null || price < 0) return;

    final location = _isAddingNew
        ? _newLocationController.text.trim()
        : _selectedLocation;

    if (location == null || location.isEmpty) return;

    await widget.onConfirm(qty, price, location, _newLat, _newLon);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          _newLat = null;
                          _newLon = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _newLat != null
                          ? AppColors.primary.withValues(alpha: 0.07)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _newLat != null
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _newLat != null
                              ? Icons.location_on_rounded
                              : Icons.add_location_alt_outlined,
                          size: 16,
                          color: _newLat != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _newLat != null
                                ? 'Đã ghim: ${_newLat!.toStringAsFixed(4)}, ${_newLon!.toStringAsFixed(4)}'
                                : 'Ghim vị trí trên bản đồ (tùy chọn)',
                            style: TextStyle(
                              fontSize: 12,
                              color: _newLat != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: _newLat != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_newLat != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() { _newLat = null; _newLon = null; }),
                            child: Icon(Icons.close_rounded,
                                size: 14,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.6)),
                          ),
                      ],
                    ),
                  ),
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

// ─── Full Screen Image ────────────────────────────────────────────────────────

class _FullScreenImagePage extends StatelessWidget {
  final String url;
  final String heroTag;

  const _FullScreenImagePage({required this.url, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                  errorBuilder: (context, error, stack) => const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
