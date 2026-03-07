import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/budget/budget_viewmodel.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BudgetViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
            tooltip: 'Chỉnh ngân sách',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BudgetSummaryCard(
              totalEstimated: vm.totalEstimated,
              totalSpent: vm.totalSpent,
              remaining: vm.remaining,
              progress: vm.progress,
            ),
            const SizedBox(height: 20),
            Text(
              'Theo danh mục',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...vm.categoryBudgets.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryBudgetCard(
                  label: c.label,
                  icon: c.icon,
                  color: c.color,
                  estimated: c.estimated,
                  spent: c.spent,
                  progress: c.progress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _BudgetSummaryCard extends StatelessWidget {
  final int totalEstimated;
  final int totalSpent;
  final int remaining;
  final double progress;

  const _BudgetSummaryCard({
    required this.totalEstimated,
    required this.totalSpent,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng ngân sách',
            style: TextStyle(color: AppColors.goldLight, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            _formatPrice(totalEstimated),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.goldLight,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã chi: ${_formatPrice(totalSpent)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Còn lại: ${_formatPrice(remaining)}',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int estimated;
  final int spent;
  final double progress;

  const _CategoryBudgetCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.estimated,
    required this.spent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatPrice(spent),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
