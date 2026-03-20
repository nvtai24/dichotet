import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shopping_models.dart';
import '../../di.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/budget/budget_viewmodel.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().loadSessions();
    });
  }

  void _openSession(ShoppingSession session) {
    final sessionVM = context.read<SessionViewModel>();
    final shoppingVM = context.read<ShoppingListViewModel>();
    final budgetVM = context.read<BudgetViewModel>();

    sessionVM.selectSession(session);
    shoppingVM.setSessionId(session.id);
    shoppingVM.loadData();
    budgetVM.loadBudget(session.id);

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

              final sessionVM = context.read<SessionViewModel>();
              Navigator.pop(ctx);
              await sessionVM.createSession(name, budget);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    final codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tham gia phiên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nhập mã 6 ký tự do người thân chia sẻ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Mã tham gia',
                  hintText: 'VD: ABC123',
                  counterText: '',
                ),
                style: const TextStyle(
                  letterSpacing: 4,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final code = codeController.text.trim();
                      if (code.length < 6) return;

                      final vm = context.read<SessionViewModel>();
                      final messenger = ScaffoldMessenger.of(context);
                      setDialogState(() => isLoading = true);
                      try {
                        final session = await vm.joinByCode(code);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _openSession(session);
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Tham gia'),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(ShoppingSession session) async {
    final sessionVM = context.read<SessionViewModel>();
    final currentIsOwner = session.isOwnedBy(sessionVM.currentUserId ?? '');
    String? code = session.joinCode;
    bool isGenerating = code == null;
    List<SessionMember> members = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Generate code + load members on first open
          if (isGenerating) {
            Future.microtask(() async {
              try {
                final newCode = await sessionVM.generateJoinCode(session.id);
                final m = await sessionVM.getSessionMembers(session.id);
                if (!ctx.mounted) return;
                setDialogState(() {
                  code = newCode;
                  members = m;
                  isGenerating = false;
                });
              } catch (_) {
                if (!ctx.mounted) return;
                setDialogState(() => isGenerating = false);
              }
            });
          } else if (members.isEmpty) {
            Future.microtask(() async {
              final m = await sessionVM.getSessionMembers(session.id);
              if (!ctx.mounted) return;
              setDialogState(() => members = m);
            });
          }

          return AlertDialog(
            title: const Text('Chia sẻ phiên'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chia sẻ mã này với người thân để cùng mua sắm',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  isGenerating
                      ? const CircularProgressIndicator()
                      : _CodeDisplay(
                          code: code ?? '',
                          onCopy: () {
                            Clipboard.setData(ClipboardData(text: code ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép mã'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                  if (members.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Thành viên (${members.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...members.map(
                      (m) => _MemberTile(
                        member: m,
                        currentUserId: sessionVM.currentUserId,
                        onRemove:
                            !currentIsOwner || m.isOwner
                            ? null
                            : () async {
                                await sessionVM.removeMember(
                                  session.id,
                                  m.userId,
                                  displayName: m.displayName,
                                );
                                final updated = await sessionVM
                                    .getSessionMembers(session.id);
                                if (!ctx.mounted) return;
                                setDialogState(() => members = updated);
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(ShoppingSession session) {
    final nameController = TextEditingController(text: session.name);
    final budgetController = TextEditingController(
      text: session.budget.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa phiên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên phiên'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(labelText: 'Ngân sách (VNĐ)'),
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
              await context.read<SessionViewModel>().updateSession(
                session.id,
                name,
                budget,
              );
            },
            child: const Text('Lưu'),
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
            onPressed: _showJoinDialog,
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Tham gia phiên',
          ),
          IconButton(
            onPressed: () async {
              final authVM = context.read<AuthViewModel>();
              final sessionVM = context.read<SessionViewModel>();
              final shoppingVM = context.read<ShoppingListViewModel>();

              final nav = Navigator.of(context);
              await authVM.signOut();
              localCacheService.clear();
              sessionVM.reset();
              shoppingVM.reset();

              if (!mounted) return;
              nav.pushReplacement(
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
        elevation: 4,
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
                    'Nhấn + để tạo phiên mới hoặc tham gia phiên của người thân',
                    style: TextStyle(color: AppColors.textHint),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final currentUserId = vm.currentUserId ?? '';
          final ownSessions = vm.sessions
              .where((s) => s.isOwnedBy(currentUserId))
              .toList();
          final sharedSessions = vm.sessions
              .where((s) => !s.isOwnedBy(currentUserId))
              .toList();

          Widget buildCard(ShoppingSession session, bool isOwner) =>
              _SessionCard(
                session: session,
                isOwner: isOwner,
                onTap: () => _openSession(session),
                onEdit: isOwner ? () => _showEditDialog(session) : null,
                onShare: isOwner ? () => _showShareDialog(session) : null,
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ── Phiên của bạn ──
              _SectionHeader(
                icon: Icons.person_rounded,
                label: 'Phiên của bạn',
                count: ownSessions.length,
              ),
              if (ownSessions.isEmpty)
                const _EmptySection(message: 'Nhấn + để tạo phiên mới')
              else
                ...ownSessions.map((s) => buildCard(s, true)),

              const SizedBox(height: 8),

              // ── Được chia sẻ ──
              _SectionHeader(
                icon: Icons.people_rounded,
                label: 'Được chia sẻ với bạn',
                count: sharedSessions.length,
              ),
              if (sharedSessions.isEmpty)
                const _EmptySection(
                  message: 'Nhấn biểu tượng 👥 trên AppBar để tham gia',
                )
              else
                ...sharedSessions.map((s) => buildCard(s, false)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _CodeDisplay extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;

  const _CodeDisplay({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            code,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded),
            color: AppColors.primary,
            tooltip: 'Sao chép',
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final SessionMember member;
  final String? currentUserId;
  final VoidCallback? onRemove;

  const _MemberTile({
    required this.member,
    required this.currentUserId,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = member.userId == currentUserId;
    final name = member.displayName ?? (isMe ? 'Bạn' : 'Thành viên');

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: member.isOwner
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.textHint.withValues(alpha: 0.2),
        child: Icon(
          member.isOwner ? Icons.star_rounded : Icons.person_rounded,
          size: 16,
          color: member.isOwner ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      title: Text(
        '$name${isMe ? ' (Bạn)' : ''}',
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: Text(
        member.isOwner ? 'Chủ phiên' : 'Thành viên',
        style: const TextStyle(fontSize: 11, color: AppColors.textHint),
      ),
      trailing: onRemove != null
          ? IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              color: AppColors.error,
            )
          : null,
    );
  }
}

// ─── Section widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textHint, fontSize: 13),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  final vn = DateTime.utc(
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
  ).add(const Duration(hours: 7));
  return '${vn.day.toString().padLeft(2, '0')}/${vn.month.toString().padLeft(2, '0')}/${vn.year}';
}

// ─── Session Card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final ShoppingSession session;
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;

  const _SessionCard({
    required this.session,
    required this.isOwner,
    required this.onTap,
    this.onEdit,
    this.onShare,
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
              Stack(
                children: [
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
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  if (!isOwner)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.people,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
              // Actions
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'share') onShare?.call();
                    if (value == 'edit') onEdit?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text('Chia sẻ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.textSecondary),
                          SizedBox(width: 10),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
