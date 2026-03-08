import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/session/session_viewmodel.dart';
import '../../viewmodels/shopping/shopping_list_viewmodel.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionViewModel>().loadSessions();
  }

  void _openSession(ShoppingSession session) {
    final sessionVM = context.read<SessionViewModel>();
    final shoppingVM = context.read<ShoppingListViewModel>();

    sessionVM.selectSession(session);
    shoppingVM.setSessionId(session.id);
    shoppingVM.loadData();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo phiên mua sắm mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên phiên',
                hintText: 'VD: Mua sắm Tết 2025',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(
                labelText: 'Ngân sách dự trù (VNĐ)',
                hintText: 'VD: 5000000',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final budget = double.tryParse(budgetController.text.trim()) ?? 0;
              if (name.isEmpty) return;

              Navigator.pop(ctx);
              await context.read<SessionViewModel>().createSession(
                name,
                budget,
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ShoppingSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa phiên mua sắm'),
        content: Text('Bạn có chắc muốn xóa "${session.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SessionViewModel>().deleteSession(session.id);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Phiên mua sắm'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final authVM = context.read<AuthViewModel>();
              await authVM.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Consumer<SessionViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: vm.loadSessions,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (vm.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có phiên mua sắm nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nhấn + để tạo phiên mới',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.sessions.length,
            itemBuilder: (context, index) {
              final session = vm.sessions[index];
              return _SessionCard(
                session: session,
                onTap: () => _openSession(session),
                onDelete: () => _confirmDelete(session),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _SessionCard extends StatelessWidget {
  final ShoppingSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = session.isActive;
    final statusColor = isActive ? AppColors.success : AppColors.textSecondary;
    final statusBg = isActive
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.divider.withValues(alpha: 0.5);
    final statusText = isActive ? 'Đang thực hiện' : 'Đã hoàn thành';
    final statusIcon = isActive
        ? Icons.timelapse_rounded
        : Icons.check_circle_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 2 : 0.5,
      color: isActive ? Colors.white : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: AppColors.primary.withValues(alpha: 0.2))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isActive
                      ? Icons.shopping_cart_rounded
                      : Icons.shopping_cart_outlined,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(session.createdAt),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.textHint,
                iconSize: 20,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
