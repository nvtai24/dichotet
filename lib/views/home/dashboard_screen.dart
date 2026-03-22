import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/home/dashboard_viewmodel.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';
import '../../core/widgets/session_app_bar.dart';
import '../main_screen.dart';
import '../shopping_list/add_item_screen.dart';
import '../shopping_list/item_detail_screen.dart';

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
        appBar: const SessionAppBar(
          title: 'Đi Chợ Tết',
          backgroundColor: Color(0xFFF4F5F9),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _HeroCountdownCard(
                daysToTet: vm.daysToTet,
                tetYear: vm.tetYear,
                tetZodiac: vm.tetZodiac,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OverviewSection(
                      progress: vm.shoppingProgress,
                      message: vm.progressMessage,
                      purchased: vm.purchasedItems,
                      total: vm.totalItems,
                      budget: vm.estimatedBudget,
                      listEstimate: vm.listEstimate,
                      spent: vm.spentBudget,
                    ),
                    const SizedBox(height: 20),
                    const _NearbyStoresSection(),
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

}

// ─── Shared Section Header ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget? trailing;
  const _SectionHeader({
    required this.emoji,
    required this.title,
    this.trailing,
  });

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
        ?trailing,
      ],
    );
  }
}

// ─── Hero Countdown Card ───────────────────────────────────────────────────

/// Đặt URL ảnh nền Tết vào đây
const String _kTetBgImageUrl =
    'https://prooackmrpvgdxyurvdr.supabase.co/storage/v1/object/public/bg/tet.jpg';

const List<String> _kTetQuotes = [
  '"Tết đến, nhà nhà sum vầy, lòng người ấm áp."',
  '"Xuân về mang theo ngàn lời chúc tốt lành."',
  '"Mỗi cái Tết là một trang mới của cuộc đời."',
  '"Hoa đào nở, lòng người rộn ràng đón xuân."',
  '"Tết là lúc yêu thương được gói vào từng món quà."',
  '"Năm mới — cơ hội mới, hy vọng mới, hạnh phúc mới."',
  '"Chuẩn bị kỹ, Tết vui trọn vẹn."',
  '"Pháo hoa rực rỡ, lòng người rạng rỡ đón xuân sang."',
  '"Sắm Tết sớm — Tết thảnh thơi, Tết trọn niềm vui."',
  '"Xuân này hơn hẳn mấy xuân qua."',
  '"Tết là hành trình trở về, không phải điểm đến."',
  '"Mùi bánh chưng, tiếng pháo — ký ức Tết không phai."',
  '"Một năm mới, một phiên bản tốt hơn của chính mình."',
  '"Đầu xuân mới, gieo hạt giống yêu thương."',
  '"Tết không chỉ là nghỉ ngơi, mà là nạp lại yêu thương."',
  '"Chúc xuân an, hạ lạc, thu thành, đông hưởng."',
  '"Vạn sự như ý, ngàn điều tốt lành theo bước xuân sang."',
  '"Gia đình là món quà lớn nhất mỗi dịp Tết về."',
  '"Xuân ý nghĩa khi bên cạnh những người ta yêu thương."',
  '"Năm cũ qua đi, mang theo những lo âu — năm mới đến, mang theo hy vọng."',
  '"Tết là khi bếp nhà luôn đỏ lửa và tiếng cười chưa bao giờ tắt."',
  '"Sắm Tết là chuẩn bị cho một mùa xuân đầy đủ và trọn vẹn."',
  '"Mỗi đồng tiền sắm Tết là một nụ cười được chuẩn bị trước."',
  '"Xuân sang, lộc mới, phúc dồi dào, tài thịnh vượng."',
  '"Đón Tết với tấm lòng biết ơn — đó là cách sống đẹp nhất."',
  '"Tết nhắc ta rằng: gia đình mới là tài sản thực sự."',
  '"Hãy sắm Tết đủ đầy — để mâm cơm sum họp thêm ý nghĩa."',
  '"Năm mới gõ cửa, mang theo muôn vàn điều tốt đẹp."',
  '"Tiếng cười con trẻ — âm thanh hay nhất của ngày Tết."',
  '"Mùa xuân là lời nhắc nhở rằng sau mọi mùa đông đều có hoa nở."',
];

class _HeroCountdownCard extends StatefulWidget {
  final int daysToTet;
  final int tetYear;
  final String tetZodiac;
  const _HeroCountdownCard({
    required this.daysToTet,
    required this.tetYear,
    required this.tetZodiac,
  });

  @override
  State<_HeroCountdownCard> createState() => _HeroCountdownCardState();
}

class _HeroCountdownCardState extends State<_HeroCountdownCard> {
  late final String _quote;

  @override
  void initState() {
    super.initState();
    final rng = DateTime.now().millisecondsSinceEpoch;
    _quote = _kTetQuotes[rng % _kTetQuotes.length];
  }

  /// "Đinh Mùi 🐐" → "Đinh Mùi"
  String _zodiacShortName(String zodiac) {
    final parts = zodiac.split(' ');
    return parts.length >= 2 ? '${parts[0]} ${parts[1]}' : zodiac;
  }

  @override
  Widget build(BuildContext context) {
    final daysToTet = widget.daysToTet;
    final tetYear = widget.tetYear;
    final tetZodiac = widget.tetZodiac;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.42),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ảnh nền (blurred)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Image.network(
              _kTetBgImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) =>
                  Container(color: AppColors.primaryDark),
            ),
          ),
          // 2. Red gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xCC7B0000),
                  Color(0xBBC62828),
                  Color(0xAAE53935),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 3. Dot decoration
          const Positioned(right: 115, bottom: 22, child: _DotGrid()),
          // 4. Content
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
                      // Title
                      Text(
                        'Tết ${_zodiacShortName(tetZodiac)} $tetYear 🧧',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(
                              color: Color(0x88000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      // Daily quote
                      Text(
                        daysToTet == 0 ? 'Chúc mừng năm mới! 🎉🎊' : _quote,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Color(0xAA000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.28),
                              AppColors.goldDark.withValues(alpha: 0.18),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.alarm_rounded,
                              size: 13,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              daysToTet == 0
                                  ? 'Hôm nay là Tết!'
                                  : '$daysToTet ngày nữa là Tết',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (daysToTet > 0) ...[
                  const SizedBox(width: 14),
                  _CountdownRing(
                    days: daysToTet,
                    zodiacEmoji: tetZodiac.split(' ').last,
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

// Triple-ring countdown circle
class _CountdownRing extends StatelessWidget {
  final int days;
  final String zodiacEmoji;
  const _CountdownRing({required this.days, required this.zodiacEmoji});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer faint ring
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        // Middle gold ring
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
        ),
        // Inner filled circle
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.13),
          ),
          child: Center(
            child: Text(zodiacEmoji, style: const TextStyle(fontSize: 36)),
          ),
        ),
      ],
    );
  }
}

// 2×2 dot grid texture
class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dotRow(0.28, 0.14),
        const SizedBox(height: 5),
        _dotRow(0.14, 0.28),
        const SizedBox(height: 5),
        _dotRow(0.20, 0.10),
      ],
    );
  }

  Widget _dotRow(double op1, double op2) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [_dot(op1), const SizedBox(width: 5), _dot(op2)],
  );

  Widget _dot(double opacity) => Container(
    width: 4,
    height: 4,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

// ─── Overview Section (merged) ─────────────────────────────────────────────

class _OverviewSection extends StatelessWidget {
  final double progress;
  final String message;
  final int purchased;
  final int total;
  final int budget;
  final int listEstimate;
  final int spent;

  const _OverviewSection({
    required this.progress,
    required this.message,
    required this.purchased,
    required this.total,
    required this.budget,
    required this.listEstimate,
    required this.spent,
  });

  static String _fmt(int price) {
    if (price == 0) return '0 đ';
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} đ';
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);
    final isDone = progress >= 1.0;
    final insights = _BudgetInsightCard.generate(
      budget: budget,
      listEstimate: listEstimate,
      spent: spent,
      progress: progress,
    );
    final topInsight = insights.isNotEmpty ? insights.first : null;

    return Container(
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
          // ── Header ──
          // const _SectionHeader(emoji: '📊', title: 'Tổng quan mua sắm'),
          // const SizedBox(height: 16),

          // ── Tiến độ ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiến độ mua sắm',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  height: 8,
                  width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDone
                          ? [const Color(0xFF66BB6A), const Color(0xFF2E7D32)]
                          : [AppColors.primaryLight, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),

          // ── Ngân sách ──
          const Text(
            'Ngân sách',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _BudgetStatCol(
                    label: 'Giới hạn',
                    amount: _fmt(budget),
                    note: budget == 0 ? 'Chưa đặt' : 'Ngân sách',
                    color: const Color(0xFF5C6BC0),
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _BudgetStatCol(
                    label: 'Dự tính',
                    amount: _fmt(listEstimate),
                    note: listEstimate == 0 ? 'Chưa có' : 'Từ danh sách',
                    color: const Color(0xFFF57C00),
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _BudgetStatCol(
                    label: 'Đã chi',
                    amount: _fmt(spent),
                    note: spent == 0 ? 'Chưa chi' : 'Thực tế',
                    color: spent > budget && budget > 0
                        ? Colors.red
                        : const Color(0xFF00897B),
                  ),
                ),
              ],
            ),
          ),
          if (budget > 0 || listEstimate > 0) ...[
            const SizedBox(height: 14),
            _BudgetProgressBar(
              budget: budget,
              listEstimate: listEstimate,
              spent: spent,
            ),
          ],

          // ── Insight ──
          if (topInsight != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.border),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: topInsight.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: topInsight.color.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topInsight.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topInsight.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: topInsight.color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          topInsight.body,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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

  const _BudgetStatCol({
    required this.label,
    required this.amount,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: const TextStyle(fontSize: 10, color: AppColors.textHint),
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
    // Progress bar: đã chi vs giới hạn (hoặc dự tính nếu chưa đặt giới hạn)
    final ref = budget > 0 ? budget : (listEstimate > 0 ? listEstimate : 1);
    final spentRatio = (spent / ref).clamp(0.0, 1.0);
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
                  // Background track (= giới hạn)
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
                              : [
                                  const Color(0xFF00BFA5),
                                  const Color(0xFF00897B),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: (isSpentOver
                                    ? Colors.red
                                    : const Color(0xFF00897B))
                                .withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
            _BarLegend(color: const Color(0xFF5C6BC0), label: 'Giới hạn'),
            const Spacer(),
            if (spent > 0)
              Text(
                isSpentOver
                    ? 'Vượt ${_OverviewSection._fmt(spent - ref)}'
                    : 'Còn ${_OverviewSection._fmt(ref - spent)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSpentOver ? Colors.red : AppColors.textSecondary,
                ),
              ),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
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

  static String _fmt(int v) => _OverviewSection._fmt(v);

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
          body:
              'Đặt ngân sách cho phiên và thêm vật phẩm để xem phân tích chi tiết.',
          color: Colors.blueGrey,
        ),
      ];
    }

    if (budget == 0 && listEstimate > 0) {
      result.add(
        _Insight(
          emoji: '💰',
          title: 'Chưa đặt ngân sách',
          body:
              'Danh sách dự tính ${_fmt(listEstimate)}. Hãy đặt ngân sách để kiểm soát chi tiêu tốt hơn.',
          color: Colors.orange,
        ),
      );
    }

    if (listEstimate == 0) {
      result.add(
        const _Insight(
          emoji: '🛒',
          title: 'Danh sách còn trống',
          body: 'Thêm vật phẩm vào danh sách để tính dự tính chi tiêu.',
          color: Colors.blue,
        ),
      );
      return result;
    }

    if (budget > 0 && spent > budget) {
      result.add(
        _Insight(
          emoji: '🚨',
          title: 'Vượt ngân sách ${_fmt(spent - budget)}!',
          body:
              'Chi tiêu thực tế đã vượt giới hạn ngân sách. Cần dừng hoặc điều chỉnh kế hoạch.',
          color: Colors.red,
        ),
      );
    } else if (budget > 0 && listEstimate > budget) {
      result.add(
        _Insight(
          emoji: '⚠️',
          title: 'Dự tính vượt ngân sách ${_fmt(listEstimate - budget)}',
          body:
              'Danh sách hiện tại ước tính vượt ngân sách. Cân nhắc bỏ bớt hoặc tìm nơi rẻ hơn.',
          color: Colors.orange,
        ),
      );
    } else if (budget > 0 && listEstimate > budget * 0.85) {
      final pct = (listEstimate * 100 ~/ budget);
      result.add(
        _Insight(
          emoji: '📊',
          title: 'Gần chạm ngân sách ($pct%)',
          body:
              'Còn ${_fmt(budget - listEstimate)} dự phòng. Hãy thận trọng khi thêm vật phẩm.',
          color: Colors.amber.shade700,
        ),
      );
    } else if (budget > 0) {
      final leftover = budget - listEstimate;
      final pctUsed = (listEstimate * 100 ~/ budget);
      result.add(
        _Insight(
          emoji: '✅',
          title: 'Ngân sách thoải mái ($pctUsed% dự tính)',
          body:
              'Còn ${_fmt(leftover)} dự phòng. Có thể thêm vật phẩm hoặc để dành.',
          color: const Color(0xFF43A047),
        ),
      );
    }

    if (spent == 0) {
      result.add(
        _Insight(
          emoji: '🛍️',
          title: 'Chưa bắt đầu chi tiêu',
          body:
              'Có ${_fmt(listEstimate)} dự tính đang chờ. Bắt đầu mua sắm nào!',
          color: Colors.blue,
        ),
      );
    } else if (progress >= 1.0) {
      if (spent < listEstimate) {
        result.add(
          _Insight(
            emoji: '🎉',
            title: 'Hoàn thành! Tiết kiệm ${_fmt(listEstimate - spent)}',
            body:
                'Mua xong toàn bộ danh sách và tiết kiệm so với dự tính. Xuất sắc!',
            color: const Color(0xFF43A047),
          ),
        );
      } else if (spent > listEstimate) {
        result.add(
          _Insight(
            emoji: '📈',
            title: 'Hoàn thành, tốn hơn dự tính ${_fmt(spent - listEstimate)}',
            body:
                'Giá thực tế cao hơn ước tính. Cân nhắc cập nhật lại giá cho lần sau.',
            color: Colors.orange,
          ),
        );
      } else {
        result.add(
          const _Insight(
            emoji: '🎯',
            title: 'Hoàn thành đúng dự tính!',
            body:
                'Chi tiêu khớp hoàn toàn với kế hoạch. Lập kế hoạch chuẩn lắm!',
            color: Color(0xFF43A047),
          ),
        );
      }
    } else if (spent > listEstimate) {
      result.add(
        _Insight(
          emoji: '📈',
          title: 'Thực tế đang cao hơn dự tính',
          body:
              'Đã chi ${_fmt(spent)} trong khi dự tính chỉ ${_fmt(listEstimate)}. Xem lại giá cả các mặt hàng.',
          color: Colors.orange,
        ),
      );
    } else {
      final remaining = listEstimate - spent;
      final donePct = (progress * 100).toInt();
      if (spent <= listEstimate * 0.5 && progress > 0.4) {
        result.add(
          _Insight(
            emoji: '👍',
            title: 'Chi tiêu hiệu quả ($donePct% hoàn thành)',
            body:
                'Chỉ dùng ${(spent * 100 ~/ listEstimate)}% dự tính. Đang tiết kiệm tốt!',
            color: const Color(0xFF43A047),
          ),
        );
      } else {
        result.add(
          _Insight(
            emoji: '🔄',
            title: '$donePct% hoàn thành, còn ${_fmt(remaining)}',
            body:
                'Đã chi ${_fmt(spent)}, ước tính cần thêm ${_fmt(remaining)} để hoàn tất danh sách.',
            color: AppColors.primary,
          ),
        );
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
            child: const _SectionHeader(
              emoji: '💡',
              title: 'Phân tích ngân sách',
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ins.color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ins.color.withValues(alpha: 0.12),
                    ),
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
                        child: Text(
                          ins.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
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

  static String _fmt(int price) => _OverviewSection._fmt(price);

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
                  onTap: () => context
                      .findAncestorStateOfType<MainScreenState>()
                      ?.switchToTab(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              color: AppColors.primary,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
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
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.categoryName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
          // Price + badge
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isChecked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
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
                Text(
                  _RecentItemsSection._fmt(totalPrice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

// ─── Nearby Stores ─────────────────────────────────────────────────────────

class _NearbyStoreData {
  final StorePrice store;
  final List<ShoppingItem> pendingItems;
  final double distanceMeters;

  const _NearbyStoreData({
    required this.store,
    required this.pendingItems,
    required this.distanceMeters,
  });
}

double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0; // Earth radius in meters
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

String _formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

class _NearbyStoresSection extends StatefulWidget {
  const _NearbyStoresSection();

  @override
  State<_NearbyStoresSection> createState() => _NearbyStoresSectionState();
}

class _NearbyStoresSectionState extends State<_NearbyStoresSection> {
  List<_NearbyStoreData> _stores = [];
  bool _loading = true;
  String? _error;
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'Vui lòng bật GPS để xem cửa hàng gần đây';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'Cần quyền truy cập vị trí';
          });
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!mounted) return;

      final vm = context.read<ShoppingListViewModel>();

      // Chỉ lấy cửa hàng từ items trong phiên hiện tại (session-scoped)
      // lat/lon null hoặc == -1 đều coi là chưa có vị trí
      bool validCoord(double? v) => v != null && v != -1.0;

      final seen = <String>{};
      final storesWithLocation = <StorePrice>[];

      for (final item in vm.allItems) {
        for (final sp in item.storePrices) {
          final key = sp.storeName.toLowerCase();
          if (seen.contains(key)) continue;
          seen.add(key);

          if (validCoord(sp.lat) && validCoord(sp.lon)) {
            // Dùng lat/lon trực tiếp từ storePrices của item
            storesWithLocation.add(sp);
          } else {
            // Tra cứu lat/lon từ storeDetails nếu item chưa có
            final detail = vm.storeDetails.where(
              (s) => s.storeName.toLowerCase() == key,
            ).firstOrNull;
            if (detail != null && validCoord(detail.lat) && validCoord(detail.lon)) {
              storesWithLocation.add(detail);
            }
          }
        }
      }

      final allItems = vm.allItems;

      final List<_NearbyStoreData> result = [];
      for (final store in storesWithLocation) {
        // Double-check trước khi dùng, tránh null-assertion fail
        if (!validCoord(store.lat) || !validCoord(store.lon)) continue;
        final dist = _haversineDistance(
          pos.latitude,
          pos.longitude,
          store.lat!,
          store.lon!,
        );
        final pendingItems = allItems
            .where(
              (item) =>
                  !item.isChecked &&
                  item.storePrices.any(
                    (sp) =>
                        sp.storeName.toLowerCase() ==
                        store.storeName.toLowerCase(),
                  ),
            )
            .toList();
        result.add(
          _NearbyStoreData(
            store: store,
            pendingItems: pendingItems,
            distanceMeters: dist,
          ),
        );
      }

      result.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      if (mounted) {
        setState(() {
          _stores = result.take(3).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Không thể lấy vị trí hiện tại';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          emoji: '📍',
          title: 'Cửa hàng gần đây',
          trailing: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : GestureDetector(
                  onTap: _load,
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (_error != null)
          _NearbyStoresError(message: _error!, onRetry: _load)
        else if (!_loading && _stores.isEmpty)
          _NearbyStoresEmpty()
        else if (!_loading)
          ...List.generate(_stores.length, (i) {
            final data = _stores[i];
            final isExpanded = _expanded.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NearbyStoreCard(
                data: data,
                rank: i + 1,
                isExpanded: isExpanded,
                onToggle: () => setState(() {
                  if (isExpanded) {
                    _expanded.remove(i);
                  } else {
                    _expanded.add(i);
                  }
                }),
                onItemTap: (item) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(item: item),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _NearbyStoresError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _NearbyStoresError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      child: Column(
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 32,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Thử lại',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyStoresEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      child: const Center(
        child: Text(
          'Chưa có cửa hàng nào có vị trí.\nHãy thêm vị trí cho cửa hàng trong danh sách mua sắm.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NearbyStoreCard extends StatelessWidget {
  final _NearbyStoreData data;
  final int rank;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<ShoppingItem> onItemTap;

  const _NearbyStoreCard({
    required this.data,
    required this.rank,
    required this.isExpanded,
    required this.onToggle,
    required this.onItemTap,
  });

  Color get _rankColor {
    if (rank == 1) return const Color(0xFF43A047);
    if (rank == 2) return AppColors.primary;
    return const Color(0xFF7B61FF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header – always visible
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _rankColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: _rankColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.store.storeName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.pendingItems.isEmpty
                              ? 'Đã mua hết ở đây'
                              : '${data.pendingItems.length} món cần mua',
                          style: TextStyle(
                            fontSize: 11,
                            color: data.pendingItems.isEmpty
                                ? const Color(0xFF43A047)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _rankColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDistance(data.distanceMeters),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _rankColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable item list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildItemList(),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    if (data.pendingItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Text(
          'Không còn món cần mua ở cửa hàng này.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        Divider(
          height: 1,
          indent: 14,
          endIndent: 14,
          color: AppColors.divider.withValues(alpha: 0.5),
        ),
        ...data.pendingItems.asMap().entries.map((e) {
          final isLast = e.key == data.pendingItems.length - 1;
          final item = e.value;
          return Column(
            children: [
              InkWell(
                onTap: () => onItemTap(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      AppNetworkImage(
                        url: item.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.quantity} ${item.unit} · ${item.categoryName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 14,
                  color: AppColors.divider.withValues(alpha: 0.4),
                ),
            ],
          );
        }),
      ],
    );
  }
}
