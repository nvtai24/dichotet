import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/settings/settings_viewmodel.dart';
import '../auth/login_screen.dart';
import '../auth/reset_password_screen.dart';
import '../session/session_list_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── Profile Card ──────────────────────────────────────────
          _buildProfileCard(context),
          const SizedBox(height: 8),

          // ── Tài khoản ─────────────────────────────────────────────
          _SectionHeader(label: 'Tài khoản'),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Hồ sơ cá nhân',
                subtitle: 'Tên, ảnh đại diện',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Đổi mật khẩu',
                subtitle: 'Bảo mật tài khoản',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResetPasswordScreen(),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Thông báo',
                subtitle: 'Nhắc nhở mua sắm, cảnh báo ngân sách',
                onTap: () {},
              ),
            ],
          ),

          // ── Dữ liệu ───────────────────────────────────────────────
          // _SectionHeader(label: 'Dữ liệu'),
          // _SettingsGroup(
          //   children: [
          //     _SettingsTile(
          //       icon: Icons.download_outlined,
          //       label: 'Xuất danh sách',
          //       subtitle: 'Export sang PDF hoặc Excel',
          //       onTap: () {},
          //     ),
          //     _SettingsTile(
          //       icon: Icons.group_outlined,
          //       label: 'Chia sẻ gia đình',
          //       subtitle: 'Đồng bộ danh sách với thành viên',
          //       trailing: const _ComingSoonBadge(),
          //       onTap: () {},
          //     ),
          //     _SettingsTile(
          //       icon: Icons.delete_outline,
          //       label: 'Xóa tất cả dữ liệu',
          //       subtitle: 'Xóa danh sách và lịch sử chi tiêu',
          //       iconColor: AppColors.error,
          //       labelColor: AppColors.error,
          //       onTap: () => _confirmDeleteData(context),
          //     ),
          //   ],
          // ),

          // ── Ứng dụng ──────────────────────────────────────────────
          _SectionHeader(label: 'Ứng dụng'),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.swap_horiz_outlined,
                label: 'Chọn phiên khác',
                subtitle: 'Chuyển sang phiên mua sắm khác',
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SessionListScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                label: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                label: 'Về ứng dụng',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () {},
              ),
            ],
          ),

          // ── Logout ────────────────────────────────────────────────
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _LogoutButton(onTap: () => _confirmLogout(context)),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
      child: Row(
        children: [
          Builder(builder: (_) {
            final url = vm.userAvatarUrl;
            if (url != null && url.isNotEmpty) {
              return ClipOval(
                child: AppNetworkImage(
                  url: url,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              );
            }
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 30,
                color: AppColors.primary,
              ),
            );
          }),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vm.userEmail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              final authVM = context.read<AuthViewModel>();
              await authVM.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─── Settings Group ───────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) const Divider(height: 1, indent: 52, endIndent: 0),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.iconColor,
    this.labelColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textHint,
                ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
