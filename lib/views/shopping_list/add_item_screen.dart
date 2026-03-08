import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategory;
  int _quantity = 1;

  List<String> _categories = [];
  List<String> _stores = [];

  // Danh sách nơi mua dự kiến
  final List<_StorePriceEntry> _storePriceEntries = [];

  @override
  void initState() {
    super.initState();
    final vm = context.read<ShoppingListViewModel>();
    _categories = vm.categoryNames;
    _stores = vm.storeNames;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    for (final entry in _storePriceEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sản phẩm')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }

    final unit = _unitController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final note = _noteController.text.trim();

    // Tạo danh sách store prices
    final storePrices = <StorePrice>[];
    for (final entry in _storePriceEntries) {
      final storeName = entry.storeName;
      final storePrice = int.tryParse(entry.priceController.text.trim()) ?? 0;
      if (storeName.isNotEmpty && storePrice > 0) {
        storePrices.add(
          StorePrice(
            storeName: storeName,
            type: StoreType.market,
            pricePerUnit: storePrice,
            lastUpdated: 'Vừa thêm',
          ),
        );
      }
    }

    final item = ShoppingItem(
      name: name,
      categoryName: _selectedCategory!,
      categoryTag: _selectedCategory!.toUpperCase(),
      categoryColor: AppColors.primary,
      quantity: _quantity,
      unit: unit.isEmpty ? 'cái' : unit,
      estimatedPrice: price,
      note: note.isEmpty ? null : note,
      storePrices: storePrices,
    );

    final vm = context.read<ShoppingListViewModel>();
    try {
      await vm.addItem(item, _selectedCategory!);
      await vm.loadData();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm sản phẩm thành công!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Giò lụa',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category
                  _FieldLabel(label: 'Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    hint: const Text('Select Category'),
                    decoration: const InputDecoration(),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quantity + Unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(label: 'Quantity'),
                            const SizedBox(height: 6),
                            _QuantityStepper(
                              value: _quantity,
                              onChanged: (v) => setState(() => _quantity = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(label: 'Unit'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                hintText: 'kg, box...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Estimate Price
                  _FieldLabel(label: 'Estimate Price / Unit (VND)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '0',
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Note
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'Note'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Special requirements, brand preferences...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Purchase Location & Price
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nơi mua dự kiến',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _addStoreEntry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_location_alt_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Thêm nơi mua',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_storePriceEntries.isEmpty) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 36,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có nơi mua nào',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nhấn "Thêm nơi mua" để lên kế hoạch',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...List.generate(_storePriceEntries.length, (index) {
                    final entry = _storePriceEntries[index];
                    return _buildStoreEntryCard(entry, index);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add to List button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: const Text(
                  'Add to List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: const Text(
        'Add New Item',
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
          'Cancel',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      leadingWidth: 90,
      actions: [
        TextButton(
          onPressed: _onSave,
          child: const Text(
            'Save',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _addStoreEntry() {
    setState(() {
      _storePriceEntries.add(_StorePriceEntry());
    });
  }

  void _removeStoreEntry(int index) {
    setState(() {
      _storePriceEntries[index].dispose();
      _storePriceEntries.removeAt(index);
    });
  }

  void _showStorePickerFor(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chọn cửa hàng',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._stores.map(
              (s) => ListTile(
                leading: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                ),
                title: Text(s),
                trailing: _storePriceEntries[index].storeName == s
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _storePriceEntries[index].storeName = s;
                    _storePriceEntries[index].nameController.text = s;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text('Nhập tên khác...'),
              onTap: () {
                Navigator.pop(context);
                // Focus vào text field để user tự nhập
                _storePriceEntries[index].nameController.clear();
                _storePriceEntries[index].storeName = '';
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreEntryCard(_StorePriceEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: store number + delete button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Nơi mua ${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removeStoreEntry(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Store name
          TextField(
            controller: entry.nameController,
            decoration: InputDecoration(
              hintText: 'Tên cửa hàng / chợ',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              suffixIcon: _stores.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => _showStorePickerFor(index),
                    )
                  : null,
            ),
            onChanged: (v) => entry.storeName = v,
          ),
          const SizedBox(height: 8),
          // Price
          TextField(
            controller: entry.priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Giá / đơn vị tại đây',
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
              suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () {
              if (value > 1) onChanged(value - 1);
            },
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

// ─── Store Price Entry Model ───────────────────────────────────────────────

class _StorePriceEntry {
  String storeName = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}
