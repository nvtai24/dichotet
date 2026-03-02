import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Tết 2027: January 26, 2027
  static final _tetDate = DateTime(2027, 1, 26);

  static int get _daysToTet {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return _tetDate.difference(todayOnly).inDays.clamp(0, 9999);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Hero card — full width, no horizontal padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _HeroCountdownCard(daysToTet: _daysToTet),
              ),
              // Remaining sections — with horizontal padding
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ShoppingCompletionSection(),
                    SizedBox(height: 20),
                    _BudgetSummarySection(),
                    SizedBox(height: 20),
                    _ShoppingDestinationsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: const Text(
        'Tet Shopping',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Countdown Card ───────────────────────────────────────────────────

class _HeroCountdownCard extends StatelessWidget {
  final int daysToTet;
  const _HeroCountdownCard({required this.daysToTet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFFEF5350)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative geometric shapes (top-right)
          Positioned(
            right: -20,
            top: -20,
            child: _DecorativeShape(size: 100, opacity: 0.12),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: _DecorativeShape(size: 80, opacity: 0.08),
          ),
          Positioned(
            right: -10,
            top: 40,
            child: _DecorativeShape(size: 60, opacity: 0.1),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Lunar New Year 2027',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preparation is in full swing!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alarm, size: 14, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        '$daysToTet ngày nữa là Tết',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeShape extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorativeShape({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.8,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
      ),
    );
  }
}

// ─── Shopping Completion ───────────────────────────────────────────────────

class _ShoppingCompletionSection extends StatelessWidget {
  const _ShoppingCompletionSection();

  static const double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ mua sắm',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _progress == 0
                          ? 'Chưa có món nào được mua'
                          : 'Sắp xong rồi, cố lên!',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Budget Summary ────────────────────────────────────────────────────────

class _BudgetSummarySection extends StatelessWidget {
  const _BudgetSummarySection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BudgetCard(
            label: 'DỰ TÍNH',
            amount: '0 ₫',
            note: 'Chưa có chi tiêu nào',
            isPrimary: false,
            icon: Icons.savings_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BudgetCard(
            label: 'ĐÃ CHI',
            amount: '0 ₫',
            note: '0% đã dùng',
            isPrimary: true,
            icon: Icons.shopping_bag_outlined,
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String label;
  final String amount;
  final String note;
  final bool isPrimary;
  final IconData icon;

  const _BudgetCard({
    required this.label,
    required this.amount,
    required this.note,
    required this.isPrimary,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppColors.primary : AppColors.surface;
    final textColor = isPrimary ? Colors.white : AppColors.textPrimary;
    final subColor = isPrimary ? Colors.white70 : AppColors.textSecondary;
    final labelColor = isPrimary ? AppColors.goldLight : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPrimary ? AppColors.primary : Colors.black).withValues(
              alpha: isPrimary ? 0.25 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: labelColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(note, style: TextStyle(color: subColor, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Categories ────────────────────────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  static const _categories = [
    (Icons.restaurant_outlined, 'Thực phẩm', AppColors.primary),
    (Icons.local_florist_outlined, 'Trang trí', Color(0xFF2E7D32)),
    (Icons.card_giftcard_outlined, 'Quà cáp', Color(0xFF6A1B9A)),
    (Icons.cake_outlined, 'Bánh kẹo', AppColors.goldDark),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Danh mục', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _categories
              .map((c) => _CategoryChip(icon: c.$1, label: c.$2, color: c.$3))
              .toList(),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shopping Destinations ─────────────────────────────────────────────────

class _ShoppingDestinationsSection extends StatelessWidget {
  const _ShoppingDestinationsSection();

  static const _destinations = [
    (
      Icons.storefront_outlined,
      'Chợ Bến Thành',
      'Hoa & Trang trí',
      '0.8km',
      true,
    ),
    (
      Icons.shopping_basket_outlined,
      'Lotte Mart',
      'Thực phẩm & Đồ uống',
      '2.4km',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Địa điểm mua sắm gần đây',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._destinations.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DestinationTile(
              icon: d.$1,
              name: d.$2,
              category: d.$3,
              distance: d.$4,
              isWalking: d.$5,
            ),
          ),
        ),
      ],
    );
  }
}

class _DestinationTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String category;
  final String distance;
  final bool isWalking;

  const _DestinationTile({
    required this.icon,
    required this.name,
    required this.category,
    required this.distance,
    required this.isWalking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(category, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                isWalking ? Icons.directions_walk : Icons.directions_car,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
