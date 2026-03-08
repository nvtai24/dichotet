import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';

class EditPurchasesScreen extends StatefulWidget {
  final ShoppingItem item;
  const EditPurchasesScreen({super.key, required this.item});

  @override
  State<EditPurchasesScreen> createState() => _EditPurchasesScreenState();
}

class _EditPurchasesScreenState extends State<EditPurchasesScreen> {
  final List<_PurchaseEntry> _purchaseEntries = [];
  final List<int> _deletedPurchaseIds = [];

  @override
  void initState() {
    super.initState();
    for (final p in widget.item.purchases) {
      _purchaseEntries.add(_PurchaseEntry.fromRecord(p));
    }
  }

  @override
  void dispose() {
    for (final entry in _purchaseEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _removePurchaseEntry(int index) {
    final entry = _purchaseEntries[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá lượt mua?'),
        content: Text('Bạn có chắc muốn xoá lượt mua #${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (entry.purchaseId != null) {
                _deletedPurchaseIds.add(entry.purchaseId!);
              }
              setState(() {
                entry.dispose();
                _purchaseEntries.removeAt(index);
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  void _onSave() async {
    final vm = context.read<ShoppingListViewModel>();
    try {
      // Delete removed purchases
      for (final id in _deletedPurchaseIds) {
        await vm.deletePurchase(id);
      }

      // Update modified purchases
      for (final pe in _purchaseEntries) {
        if (pe.purchaseId == null) continue;
        final newQty = int.tryParse(pe.quantityController.text.trim()) ?? 0;
        final newPrice = int.tryParse(pe.priceController.text.trim()) ?? 0;
        if (newQty != pe.originalQuantity || newPrice != pe.originalPrice) {
          await vm.updatePurchase(pe.purchaseId!, newQty, newPrice);
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật lịch sử mua hàng!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chỉnh sửa lượt mua',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Huỷ',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 70,
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: _purchaseEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Không có lượt mua nào',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  _buildSummaryCard(),
                  const SizedBox(height: 16),

                  // Purchase entries
                  ...List.generate(_purchaseEntries.length, (index) {
                    return _buildPurchaseEntryCard(
                      _purchaseEntries[index],
                      index,
                    );
                  }),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onSave,
                      icon: const Icon(Icons.save_outlined, size: 20),
                      label: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    int totalQty = 0;
    int totalSpent = 0;
    for (final pe in _purchaseEntries) {
      final qty = int.tryParse(pe.quantityController.text.trim()) ?? 0;
      final price = int.tryParse(pe.priceController.text.trim()) ?? 0;
      totalQty += qty;
      totalSpent += qty * price;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_purchaseEntries.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF43A047),
                  ),
                ),
                const Text(
                  'Lượt mua',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalQty ${widget.item.unit}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF43A047),
                  ),
                ),
                const Text(
                  'Tổng SL',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(
            child: Column(
              children: [
                Text(
                  _formatPriceShort(totalSpent),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF43A047),
                  ),
                ),
                const Text(
                  'Tổng chi',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseEntryCard(_PurchaseEntry entry, int index) {
    final date = entry.purchasedAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 0 : 10),
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
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
                    if (entry.locationName != null &&
                        entry.locationName!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              entry.locationName!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
              GestureDetector(
                onTap: () => _removePurchaseEntry(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Số lượng',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: entry.priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Giá/đơn vị',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text(
                        '₫',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurchaseEntry {
  final int? purchaseId;
  final int originalQuantity;
  final int originalPrice;
  final DateTime purchasedAt;
  final String? locationName;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  _PurchaseEntry({
    this.purchaseId,
    required this.originalQuantity,
    required this.originalPrice,
    required this.purchasedAt,
    this.locationName,
  }) : quantityController = TextEditingController(
         text: originalQuantity.toString(),
       ),
       priceController = TextEditingController(text: originalPrice.toString());

  factory _PurchaseEntry.fromRecord(PurchaseRecord record) {
    return _PurchaseEntry(
      purchaseId: record.id,
      originalQuantity: record.quantity,
      originalPrice: record.pricePerUnit,
      purchasedAt: record.purchasedAt,
      locationName: record.locationName,
    );
  }

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}
