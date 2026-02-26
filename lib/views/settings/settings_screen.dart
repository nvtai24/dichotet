import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          _SettingsHeader(label: 'Tổng quan'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Hồ sơ',
            subtitle: 'Tên, thông tin cá nhân',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            subtitle: 'Nhắc nhở, cảnh báo ngân sách',
            onTap: () {},
          ),
          const Divider(height: 1),
          _SettingsHeader(label: 'Dữ liệu'),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Xuất danh sách',
            subtitle: 'Export sang PDF, Excel',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.share_outlined,
            title: 'Chia sẻ gia đình',
            subtitle: 'Đồng bộ danh sách với thành viên',
            trailing: _ComingSoonBadge(),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Xóa dữ liệu',
            subtitle: 'Xóa tất cả danh sách và chi tiêu',
            titleColor: AppColors.error,
            onTap: () {},
          ),
          const Divider(height: 1),
          _SettingsHeader(label: 'Ứng dụng'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            subtitle: 'Phiên bản 1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '🏮 Chúc mừng năm mới 🏮',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String label;
  const _SettingsHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: titleColor ?? AppColors.primary),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: titleColor,
            ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: const Text(
        'Sắp có',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.goldDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
