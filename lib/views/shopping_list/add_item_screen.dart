import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';
import '../location/location_picker_screen.dart';

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

  XFile? _selectedImage;
  bool _isUploadingImage = false;

  List<String> _categories = [];

  // Danh sách nơi mua dự kiến
  final List<_StorePriceEntry> _storePriceEntries = [];

  @override
  void initState() {
    super.initState();
    final vm = context.read<ShoppingListViewModel>();
    _categories = vm.categoryNames;

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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) setState(() => _selectedImage = file);
  }

  void _showImageSourceSheet() {
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
              'Chọn ảnh sản phẩm',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xoá ảnh', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _selectedImage = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
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

    // Validate tên cửa hàng không trùng nhau
    final storeNames = _storePriceEntries
        .map((e) => e.storeName.trim().toLowerCase())
        .where((n) => n.isNotEmpty)
        .toList();
    final uniqueNames = storeNames.toSet();
    if (uniqueNames.length < storeNames.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên cửa hàng không được trùng nhau')),
      );
      return;
    }

    // Tạo danh sách store prices
    final storePrices = <StorePrice>[];
    for (final entry in _storePriceEntries) {
      final storeName = entry.storeName;
      final storePrice = int.tryParse(entry.priceController.text.trim()) ?? 0;
      if (storeName.isNotEmpty && storePrice > 0) {
        storePrices.add(
          StorePrice(
            storeName: storeName,
            pricePerUnit: storePrice,
            lastUpdated: 'Vừa thêm',
            lat: entry.lat,
            lon: entry.lon,
          ),
        );
      }
    }

    final vm = context.read<ShoppingListViewModel>();

    // Upload ảnh nếu có
    String? imageUrl;
    if (_selectedImage != null) {
      setState(() => _isUploadingImage = true);
      try {
        final bytes = await _selectedImage!.readAsBytes();
        final ext = _selectedImage!.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        imageUrl = await vm.uploadItemImage(bytes, fileName);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi upload ảnh: $e')),
        );
        setState(() => _isUploadingImage = false);
        return;
      }
      if (mounted) setState(() => _isUploadingImage = false);
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
      imageUrl: imageUrl,
      storePrices: storePrices,
    );

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
      backgroundColor: AppColors.background,
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
                  _FieldLabel(label: 'Tên sản phẩm'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: Giò lụa',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category
                  _FieldLabel(label: 'Danh mục'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    hint: const Text('Chọn danh mục'),
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
                            _FieldLabel(label: 'Số lượng'),
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
                            _FieldLabel(label: 'Đơn vị'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                hintText: 'kg, hộp...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Estimate Price
                  _FieldLabel(label: 'Giá ước tính / đơn vị (VND)'),
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

            // Image
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'Ảnh sản phẩm'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImage!.path),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 36,
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thêm ảnh sản phẩm',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Chụp ảnh hoặc chọn từ thư viện',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Text(
                        'Đổi ảnh',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Note
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'Ghi chú'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Yêu cầu đặc biệt, thương hiệu ưa thích...',
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
                  'Thêm vào danh sách',
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
        'Thêm sản phẩm mới',
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
      leadingWidth: 90,
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


  Widget _buildStoreEntryCard(_StorePriceEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.storefront_outlined, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 7),
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
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Store name + map pin button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: entry.nameController,
                  decoration: InputDecoration(
                    hintText: 'Tên cửa hàng / chợ',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixIcon: null,
                  ),
                  onChanged: (v) => entry.storeName = v,
                ),
              ),
              const SizedBox(width: 8),
              // Compact map pin button
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<LatLng?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationPickerScreen(
                        storeName: entry.storeName.isNotEmpty ? entry.storeName : null,
                        initialLocation: entry.hasLocation
                            ? LatLng(entry.lat!, entry.lon!)
                            : null,
                      ),
                    ),
                  );
                  if (result == null && entry.hasLocation) {
                    setState(() { entry.lat = null; entry.lon = null; });
                  } else if (result != null) {
                    setState(() {
                      entry.lat = result.latitude;
                      entry.lon = result.longitude;
                    });
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: entry.hasLocation
                        ? AppColors.primary
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    entry.hasLocation
                        ? Icons.location_on_rounded
                        : Icons.add_location_alt_outlined,
                    size: 20,
                    color: entry.hasLocation
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          // Location chip
          if (entry.hasLocation) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 11, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.lat!.toStringAsFixed(5)}, ${entry.lon!.toStringAsFixed(5)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() { entry.lat = null; entry.lon = null; }),
                    child: Icon(
                      Icons.close_rounded,
                      size: 11,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Price
          TextField(
            controller: entry.priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Giá / đơn vị',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: Icon(Icons.sell_outlined, size: 18, color: AppColors.textSecondary),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text(
                  '₫',
                  style: TextStyle(
                    fontSize: 15,
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

class _QuantityStepper extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  State<_QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<_QuantityStepper> {
  late final TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(_QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitEdit() {
    final parsed = int.tryParse(_controller.text.trim());
    final newVal = (parsed != null && parsed > 0) ? parsed : widget.value;
    _controller.text = '$newVal';
    setState(() => _editing = false);
    widget.onChanged(newVal);
  }

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
              if (widget.value > 1) widget.onChanged(widget.value - 1);
            },
          ),
          Expanded(
            child: _editing
                ? TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _commitEdit(),
                    onTapOutside: (_) => _commitEdit(),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() => _editing = true);
                      _controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controller.text.length,
                      );
                    },
                    child: Text(
                      '${widget.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
          ),
          _StepButton(icon: Icons.add, onTap: () => widget.onChanged(widget.value + 1)),
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
  double? lat;
  double? lon;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool get hasLocation => lat != null && lon != null;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}
