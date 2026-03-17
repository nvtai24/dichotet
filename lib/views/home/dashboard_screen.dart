import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/home/dashboard_viewmodel.dart';
import '../main_screen.dart';
import '../shopping_list/add_item_screen.dart';

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
        backgroundColor: const Color(0xFFF4F5F9),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _HeroCountdownCard(
                daysToTet: vm.daysToTet,
                tetYear: vm.tetYear,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShoppingCompletionSection(
                      progress: vm.shoppingProgress,
                      message: vm.progressMessage,
                      purchased: vm.purchasedItems,
                      total: vm.totalItems,
                    ),
                    const SizedBox(height: 20),
                    _BudgetSummarySection(
                      budget: vm.estimatedBudget,
                      listEstimate: vm.listEstimate,
                      spent: vm.spentBudget,
                      progress: vm.shoppingProgress,
                    ),
                    const SizedBox(height: 20),
                    _RecentItemsSection(items: vm.recentItems),
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
      backgroundColor: const Color(0xFFF4F5F9),
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: const Text(
        'Mua Sắm Tết',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.person_outline, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Section Header ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.emoji, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Hero Countdown Card ───────────────────────────────────────────────────

class _HeroCountdownCard extends StatelessWidget {
  final int daysToTet;
  final int tetYear;
  const _HeroCountdownCard({required this.daysToTet, required this.tetYear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 185,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFFEF5350)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(left: -25, top: -25, child: _DecorativeShape(size: 90, opacity: 0.07)),
          Positioned(left: 40, bottom: -35, child: _DecorativeShape(size: 70, opacity: 0.06)),
          Positioned(right: -15, bottom: -15, child: _DecorativeShape(size: 55, opacity: 0.06)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tết Nguyên Đán $tetYear 🧧',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        daysToTet == 0
                            ? 'Chúc mừng năm mới! 🎉🎊'
                            : 'Lên danh sách, sắm Tết thôi nào!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm, size: 13, color: AppColors.gold),
                            const SizedBox(width: 5),
                            Text(
                              daysToTet == 0 ? 'Hôm nay là Tết!' : '$daysToTet ngày nữa là Tết',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (daysToTet > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.65),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$daysToTet',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'ngày',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
  final int purchased;
  final int total;

  const _ShoppingCompletionSection({
    required this.progress,
    required this.message,
    required this.purchased,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);
    final remaining = total - purchased;
    final isDone = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                    const Text(
                      'Tiến độ mua sắm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDone
                        ? [const Color(0xFF43A047), const Color(0xFF2E7D32)]
                        : [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Container(
                  height: 10,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  height: 10,
                  width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDone
                          ? [const Color(0xFF66BB6A), const Color(0xFF2E7D32)]
                          : [AppColors.primaryLight, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  icon: Icons.check_circle_outline,
                  label: '$purchased đã mua',
                  color: const Color(0xFF43A047),
                ),
                const SizedBox(width: 8),
                if (remaining > 0)
                  _StatChip(
                    icon: Icons.radio_button_unchecked,
                    label: '$remaining còn lại',
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Budget Summary ────────────────────────────────────────────────────────

class _BudgetSummarySection extends StatelessWidget {
  final int budget;
  final int listEstimate;
  final int spent;
  final double progress;

  const _BudgetSummarySection({
    required this.budget,
    required this.listEstimate,
    required this.spent,
    required this.progress,
  });

  static String fmt(int price) {
    if (price == 0) return '0 ₫';
    if (price >= 1000000) {
      final m = price / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M ₫';
    }
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k ₫';
    return '$price ₫';
  }

  @override
  Widget build(BuildContext context) {
    final insights = _BudgetInsightCard.generate(
      budget: budget,
      listEstimate: listEstimate,
      spent: spent,
      progress: progress,
    );

    return Column(
      children: [
        // ── Unified budget card ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(emoji: '💰', title: 'Tổng quan ngân sách'),
              const SizedBox(height: 16),

              // ── 3 stat columns ──
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _BudgetStatCol(
                        label: 'Ngân sách',
                        amount: fmt(budget),
                        note: budget == 0 ? 'Chưa đặt' : 'Giới hạn',
                        color: AppColors.primary,
                        icon: Icons.savings_outlined,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _BudgetStatCol(
                        label: 'Dự tính',
                        amount: fmt(listEstimate),
                        note: listEstimate == 0 ? 'Chưa có' : 'Từ danh sách',
                        color: const Color(0xFF7B61FF),
                        icon: Icons.calculate_outlined,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _BudgetStatCol(
                        label: 'Đã chi',
                        amount: fmt(spent),
                        note: spent == 0 ? 'Chưa chi' : 'Thực tế',
                        color: spent > budget && budget > 0
                            ? Colors.red
                            : const Color(0xFF00897B),
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Multi-color progress bar ──
              if (budget > 0 || listEstimate > 0) ...[
                const SizedBox(height: 16),
                _BudgetProgressBar(
                  budget: budget,
                  listEstimate: listEstimate,
                  spent: spent,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),
        // ── Insight card ──
        _BudgetInsightCard(insights: insights),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.border,
    );
  }
}

class _BudgetStatCol extends StatelessWidget {
  final String label;
  final String amount;
  final String note;
  final Color color;
  final IconData icon;

  const _BudgetStatCol({
    required this.label,
    required this.amount,
    required this.note,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressBar extends StatelessWidget {
  final int budget;
  final int listEstimate;
  final int spent;

  const _BudgetProgressBar({
    required this.budget,
    required this.listEstimate,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final ref = budget > 0 ? budget : (listEstimate > 0 ? listEstimate : 1);
    final spentRatio = (spent / ref).clamp(0.0, 1.0);
    final estimateRatio = (listEstimate / ref).clamp(0.0, 1.0);
    final isSpentOver = spent > ref;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (_, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 24,
              child: Stack(
                children: [
                  // Background track
                  Positioned(
                    top: 7,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Estimate fill (purple, lighter)
                  if (listEstimate > 0 && budget > 0)
                    Positioned(
                      top: 7,
                      left: 0,
                      child: Container(
                        height: 10,
                        width: w * estimateRatio,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  // Spent fill
                  Positioned(
                    top: 7,
                    left: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      height: 10,
                      width: w * spentRatio,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSpentOver
                              ? [Colors.red.shade300, Colors.red.shade600]
                              : [const Color(0xFF00BFA5), const Color(0xFF00897B)],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: (isSpentOver ? Colors.red : const Color(0xFF00897B))
                                .withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Estimate marker pin
                  if (listEstimate > 0 && budget > 0 && listEstimate <= budget)
                    Positioned(
                      left: w * estimateRatio - 1,
                      top: 4,
                      child: Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          children: [
            _BarLegend(color: const Color(0xFF00897B), label: 'Đã chi'),
            const SizedBox(width: 12),
            _BarLegend(color: const Color(0xFF7B61FF).withValues(alpha: 0.5), label: 'Dự tính'),
            if (budget > 0) ...[
              const Spacer(),
              Text(
                budget > 0 && spent > 0
                    ? 'Còn ${_BudgetSummarySection.fmt(budget - spent)}'
                    : '',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _BarLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _BarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Budget Insight Card ──────────────────────────────────────────────────

class _Insight {
  final String emoji;
  final String title;
  final String body;
  final Color color;
  const _Insight({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });
}

class _BudgetInsightCard extends StatelessWidget {
  final List<_Insight> insights;
  const _BudgetInsightCard({required this.insights});

  static String _fmt(int v) => _BudgetSummarySection.fmt(v);

  static List<_Insight> generate({
    required int budget,
    required int listEstimate,
    required int spent,
    required double progress,
  }) {
    final result = <_Insight>[];

    if (budget == 0 && listEstimate == 0 && spent == 0) {
      return [
        const _Insight(
          emoji: '📋',
          title: 'Chưa có dữ liệu',
          body: 'Đặt ngân sách cho phiên và thêm vật phẩm để xem phân tích chi tiết.',
          color: Colors.blueGrey,
        ),
      ];
    }

    if (budget == 0 && listEstimate > 0) {
      result.add(_Insight(
        emoji: '💰',
        title: 'Chưa đặt ngân sách',
        body: 'Danh sách dự tính ${_fmt(listEstimate)}. Hãy đặt ngân sách để kiểm soát chi tiêu tốt hơn.',
        color: Colors.orange,
      ));
    }

    if (listEstimate == 0) {
      result.add(const _Insight(
        emoji: '🛒',
        title: 'Danh sách còn trống',
        body: 'Thêm vật phẩm vào danh sách để tính dự tính chi tiêu.',
        color: Colors.blue,
      ));
      return result;
    }

    if (budget > 0 && spent > budget) {
      result.add(_Insight(
        emoji: '🚨',
        title: 'Vượt ngân sách ${_fmt(spent - budget)}!',
        body: 'Chi tiêu thực tế đã vượt giới hạn ngân sách. Cần dừng hoặc điều chỉnh kế hoạch.',
        color: Colors.red,
      ));
    } else if (budget > 0 && listEstimate > budget) {
      result.add(_Insight(
        emoji: '⚠️',
        title: 'Dự tính vượt ngân sách ${_fmt(listEstimate - budget)}',
        body: 'Danh sách hiện tại ước tính vượt ngân sách. Cân nhắc bỏ bớt hoặc tìm nơi rẻ hơn.',
        color: Colors.orange,
      ));
    } else if (budget > 0 && listEstimate > budget * 0.85) {
      final pct = (listEstimate * 100 ~/ budget);
      result.add(_Insight(
        emoji: '📊',
        title: 'Gần chạm ngân sách ($pct%)',
        body: 'Còn ${_fmt(budget - listEstimate)} dự phòng. Hãy thận trọng khi thêm vật phẩm.',
        color: Colors.amber.shade700,
      ));
    } else if (budget > 0) {
      final leftover = budget - listEstimate;
      final pctUsed = (listEstimate * 100 ~/ budget);
      result.add(_Insight(
        emoji: '✅',
        title: 'Ngân sách thoải mái ($pctUsed% dự tính)',
        body: 'Còn ${_fmt(leftover)} dự phòng. Có thể thêm vật phẩm hoặc để dành.',
        color: const Color(0xFF43A047),
      ));
    }

    if (spent == 0) {
      result.add(_Insight(
        emoji: '🛍️',
        title: 'Chưa bắt đầu chi tiêu',
        body: 'Có ${_fmt(listEstimate)} dự tính đang chờ. Bắt đầu mua sắm nào!',
        color: Colors.blue,
      ));
    } else if (progress >= 1.0) {
      if (spent < listEstimate) {
        result.add(_Insight(
          emoji: '🎉',
          title: 'Hoàn thành! Tiết kiệm ${_fmt(listEstimate - spent)}',
          body: 'Mua xong toàn bộ danh sách và tiết kiệm so với dự tính. Xuất sắc!',
          color: const Color(0xFF43A047),
        ));
      } else if (spent > listEstimate) {
        result.add(_Insight(
          emoji: '📈',
          title: 'Hoàn thành, tốn hơn dự tính ${_fmt(spent - listEstimate)}',
          body: 'Giá thực tế cao hơn ước tính. Cân nhắc cập nhật lại giá cho lần sau.',
          color: Colors.orange,
        ));
      } else {
        result.add(const _Insight(
          emoji: '🎯',
          title: 'Hoàn thành đúng dự tính!',
          body: 'Chi tiêu khớp hoàn toàn với kế hoạch. Lập kế hoạch chuẩn lắm!',
          color: Color(0xFF43A047),
        ));
      }
    } else if (spent > listEstimate) {
      result.add(_Insight(
        emoji: '📈',
        title: 'Thực tế đang cao hơn dự tính',
        body: 'Đã chi ${_fmt(spent)} trong khi dự tính chỉ ${_fmt(listEstimate)}. Xem lại giá cả các mặt hàng.',
        color: Colors.orange,
      ));
    } else {
      final remaining = listEstimate - spent;
      final donePct = (progress * 100).toInt();
      if (spent <= listEstimate * 0.5 && progress > 0.4) {
        result.add(_Insight(
          emoji: '👍',
          title: 'Chi tiêu hiệu quả ($donePct% hoàn thành)',
          body: 'Chỉ dùng ${(spent * 100 ~/ listEstimate)}% dự tính. Đang tiết kiệm tốt!',
          color: const Color(0xFF43A047),
        ));
      } else {
        result.add(_Insight(
          emoji: '🔄',
          title: '$donePct% hoàn thành, còn ${_fmt(remaining)}',
          body: 'Đã chi ${_fmt(spent)}, ước tính cần thêm ${_fmt(remaining)} để hoàn tất danh sách.',
          color: AppColors.primary,
        ));
      }
    }

    return result.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: const _SectionHeader(emoji: '💡', title: 'Phân tích ngân sách'),
          ),
          const SizedBox(height: 12),
          // Insight rows
          ...insights.asMap().entries.map((e) {
            final ins = e.value;
            final isLast = e.key == insights.length - 1;
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: ins.color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ins.color.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ins.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(ins.emoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ins.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ins.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ins.body,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isLast ? 12 : 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Recent Items ──────────────────────────────────────────────────────────

class _RecentItemsSection extends StatelessWidget {
  final List<ShoppingItem> items;
  const _RecentItemsSection({required this.items});

  static String _fmt(int price) {
    if (price == 0) return '0 ₫';
    if (price >= 1000000) {
      final m = price / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M ₫';
    }
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k ₫';
    return '$price ₫';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          emoji: '🛒',
          title: 'Vừa thêm gần đây',
          trailing: items.isNotEmpty
              ? GestureDetector(
                  onTap: () =>
                      context.findAncestorStateOfType<MainScreenState>()?.switchToTab(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _EmptyRecentItems()
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecentItemTile(item: item),
            ),
          ),
      ],
    );
  }
}

class _EmptyRecentItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Chưa có sản phẩm nào',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hãy thêm món đồ đầu tiên của bạn!',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemScreen()),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm vật phẩm'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentItemTile extends StatelessWidget {
  final ShoppingItem item;
  const _RecentItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final totalPrice = item.quantity * item.estimatedPrice;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: item.categoryColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          const SizedBox(width: 12),
          // Image
          AppNetworkImage(
            url: item.imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isChecked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 10, color: Color(0xFF43A047)),
                            SizedBox(width: 3),
                            Text(
                              'Đã mua',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF43A047),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: item.categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              _RecentItemsSection._fmt(totalPrice),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
