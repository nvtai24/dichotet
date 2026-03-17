import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../viewmodels/settings/settings_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<SettingsViewModel>();
    _firstNameController.text = vm.profile?.firstName ?? '';
    _lastNameController.text = vm.profile?.lastName ?? '';
    _phoneController.text = vm.profile?.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file != null) setState(() => _selectedImage = file);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Chụp ảnh'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SettingsViewModel>();
    String? imageUrl = vm.profile?.imageUrl;

    if (_selectedImage != null) {
      setState(() => _isUploadingImage = true);
      try {
        final bytes = await File(_selectedImage!.path).readAsBytes();
        final userId = vm.profile?.id ?? 'user';
        final ext = _selectedImage!.path.split('.').last;
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        imageUrl = await vm.uploadAvatar(bytes, fileName);
        if (imageUrl == null) throw Exception('Upload thất bại');
      } catch (e) {
        if (!mounted) return;
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi upload ảnh: $e')),
        );
        return;
      }
      setState(() => _isUploadingImage = false);
    }

    final success = await vm.updateName(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      imageUrl: imageUrl,
    );

    if (!mounted) return;

    if (success) {
      await vm.loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar ────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        clipBehavior: Clip.antiAlias,
                        child: _selectedImage != null
                            ? Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              )
                            : Consumer<SettingsViewModel>(
                                builder: (_, vm, _) {
                                  final url = vm.userAvatarUrl;
                                  if (url != null && url.isNotEmpty) {
                                    return AppNetworkImage(
                                      url: url,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return Container(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── First Name ────────────────────────────────────────
              const _FieldLabel(label: 'Họ'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Nguyễn',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Last Name ─────────────────────────────────────────
              const _FieldLabel(label: 'Tên'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Văn A',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // ── SĐT ─────────────────────────────────────────────────
              const _FieldLabel(label: 'Số điện thoại'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '0901 234 567',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              // ── Email (readonly) ──────────────────────────────────
              const _FieldLabel(label: 'Email'),
              const SizedBox(height: 6),
              Consumer<SettingsViewModel>(
                builder: (_, vm, _) => TextFormField(
                  initialValue: vm.userEmail,
                  enabled: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Save button ───────────────────────────────────────
              Consumer<SettingsViewModel>(
                builder: (_, vm, _) => ElevatedButton(
                  onPressed: vm.isLoading ? null : _onSave,
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
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
