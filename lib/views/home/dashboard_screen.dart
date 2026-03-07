import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/home/dashboard_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _HeroCountdownCard(daysToTet: vm.daysToTet),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShoppingCompletionSection(
                      progress: vm.shoppingProgress,
                      message: vm.progressMessage,
                    ),
                    const SizedBox(height: 20),
                    _BudgetSummarySection(
                      estimated: vm.estimatedBudget,
                      spent: vm.spentBudget,
                    ),
                    const SizedBox(height: 20),
                    _ShoppingDestinationsSection(destinations: vm.destinations),
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
  final double progress;
  final String message;
  const _ShoppingCompletionSection({
    required this.progress,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);
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
                    Text(message, style: Theme.of(context).textTheme.bodySmall),
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
              value: progress,
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
  final int estimated;
  final int spent;
  const _BudgetSummarySection({required this.estimated, required this.spent});

  String _formatPrice(int price) {
    if (price == 0) return '0 ₫';
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  @override
  Widget build(BuildContext context) {
    final pct = estimated == 0 ? 0 : (spent * 100 ~/ estimated);
    return Row(
      children: [
        Expanded(
          child: _BudgetCard(
            label: 'NGÂN SÁCH',
            amount: _formatPrice(estimated),
            note: estimated == 0 ? 'Chưa có chi tiêu nào' : 'Tổng dự tính',
            isPrimary: false,
            icon: Icons.savings_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BudgetCard(
            label: 'ĐÃ CHI',
            amount: _formatPrice(spent),
            note: '$pct% đã dùng',
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

// ─── Shopping Destinations ─────────────────────────────────────────────────

class _ShoppingDestinationsSection extends StatelessWidget {
  final List<Destination> destinations;
  const _ShoppingDestinationsSection({required this.destinations});

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
        ...destinations.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DestinationTile(
              icon: d.isWalking
                  ? Icons.storefront_outlined
                  : Icons.shopping_basket_outlined,
              name: d.name,
              category: d.category,
              distance: d.distance,
              isWalking: d.isWalking,
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
