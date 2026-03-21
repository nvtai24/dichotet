import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/session_app_bar.dart';
import '../../viewmodels/budget/budget_viewmodel.dart';
import '../../viewmodels/session/session_viewmodel.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/currency_formatter.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetVM = context.read<BudgetViewModel>();
      final sessionVM = context.read<SessionViewModel>();
      final sid = sessionVM.selectedSession?.id;
      if (sid != null && !budgetVM.isLoading) {
        budgetVM.loadBudget(sid);
      }
    });
  }

  void _showEditBudgetDialog() {
    final sessionVM = context.read<SessionViewModel>();
    final session = sessionVM.selectedSession;
    if (session == null) return;

    final controller = TextEditingController(
      text: formatCurrencyInitial(session.budget),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh ngân sách'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Ngân sách (VNĐ)'),
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final budget = parseCurrency(controller.text);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              try {
                await sessionVM.updateSession(session.id, session.name, budget);
                if (!mounted) return;
                context.read<BudgetViewModel>().loadBudget(session.id);
              } catch (e) {
                showErrorSnackBar(messenger, e);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BudgetViewModel>();

    Widget body;
    if (vm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => vm.loadBudget(
                context.read<SessionViewModel>().selectedSession!.id,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    } else {
      body = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BudgetSummaryCard(
              totalBudget: vm.totalBudget,
              totalEstimated: vm.totalEstimated,
              totalSpent: vm.totalSpent,
              remaining: vm.remaining,
              progress: vm.progress,
              onEdit: _showEditBudgetDialog,
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
                  estimated: c.estimated,
                  spent: c.spent,
                  progress: c.progress,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SessionAppBar(title: 'Ngân sách'),
      body: body,
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
  final int totalBudget;
  final int totalEstimated;
  final int totalSpent;
  final int remaining;
  final double progress;
  final VoidCallback? onEdit;

  const _BudgetSummaryCard({
    required this.totalBudget,
    required this.totalEstimated,
    required this.totalSpent,
    required this.remaining,
    required this.progress,
    this.onEdit,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatPrice(totalBudget),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                  tooltip: 'Chỉnh ngân sách',
                ),
            ],
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Dự tính',
                  amount: _formatPrice(totalEstimated),
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Đã chi',
                  amount: _formatPrice(totalSpent),
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: remaining < 0 ? 'Vượt' : 'Còn lại',
                  amount: _formatPrice(remaining.abs()),
                  color: remaining < 0 ? const Color(0xFFFF6B6B) : AppColors.goldLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CategoryBudgetCard extends StatelessWidget {
  final String label;
  final int estimated;
  final int spent;
  final double progress;

  const _CategoryBudgetCard({
    required this.label,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Dự tính: ${_formatPrice(estimated)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã chi: ${_formatPrice(spent)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
