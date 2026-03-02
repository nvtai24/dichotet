import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _TetBanner(),
              title: const Text('Danh sách mua sắm'),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(title: 'Thực phẩm', icon: Icons.restaurant),
                const SizedBox(height: 8),
                _EmptyCategoryCard(
                  label: 'Chưa có món nào',
                  hint: 'Nhấn + để thêm',
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Bánh kẹo - Mứt Tết', icon: Icons.cake),
                const SizedBox(height: 8),
                _EmptyCategoryCard(
                  label: 'Chưa có món nào',
                  hint: 'Nhấn + để thêm',
                ),
                const SizedBox(height: 16),
                _SectionHeader(
                    title: 'Trang trí - Hoa', icon: Icons.local_florist),
                const SizedBox(height: 8),
                _EmptyCategoryCard(
                  label: 'Chưa có món nào',
                  hint: 'Nhấn + để thêm',
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Quà cáp', icon: Icons.card_giftcard),
                const SizedBox(height: 8),
                _EmptyCategoryCard(
                  label: 'Chưa có món nào',
                  hint: 'Nhấn + để thêm',
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TetBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFFE53935)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chào Xuân Bính Ngọ 🎊',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đi chợ Tết\nthông minh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('🏮', style: TextStyle(fontSize: 48)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          '0 món',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _EmptyCategoryCard extends StatelessWidget {
  final String label;
  final String hint;

  const _EmptyCategoryCard({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            hint,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
