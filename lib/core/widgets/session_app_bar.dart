import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../viewmodels/home/dashboard_viewmodel.dart';
import '../../views/session/action_log_screen.dart';

/// App bar dùng chung cho Dashboard / ShoppingList / Budget
/// - Trái: nhật ký hoạt động
/// - Phải: lịch đếm ngược Tết
class SessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  const SessionAppBar({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xFFF4F5F9),
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tetDate = context.watch<DashboardViewModel>().nextTetDate;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.calendar_month_outlined,
          size: 22,
          color: AppColors.textPrimary,
        ),
        onPressed: () => _showCalendar(context, tetDate),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.history_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActionLogScreen()),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showCalendar(BuildContext context, DateTime tetDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TetCalendarSheet(tetDate: tetDate),
    );
  }
}

// ─── Calendar Sheet (moved from dashboard_screen.dart) ─────────────────────

class _TetCalendarSheet extends StatefulWidget {
  final DateTime tetDate;
  const _TetCalendarSheet({required this.tetDate});

  @override
  State<_TetCalendarSheet> createState() => _TetCalendarSheetState();
}

class _TetCalendarSheetState extends State<_TetCalendarSheet> {
  late DateTime _focusedMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedMonth = DateTime(_today.year, _today.month);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: _buildCalendar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final daysLeft = widget.tetDate.difference(_today).inDays;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.celebration_outlined,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đếm ngược Tết',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                Text(
                  daysLeft > 0 ? 'Còn $daysLeft ngày' : 'Hôm nay là Tết! 🎉',
                  style: TextStyle(
                      color: daysLeft <= 7
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          _NavBtn(
            icon: Icons.chevron_left,
            onTap: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            }),
          ),
          const SizedBox(width: 4),
          _NavBtn(
            icon: Icons.chevron_right,
            onTap: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startOffset = (firstDay.weekday % 7); // 0=Sun
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final monthNames = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            '${monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          ...List.generate(rows, (r) {
            return Row(
              children: List.generate(7, (c) {
                final cellIndex = r * 7 + c;
                final day = cellIndex - startOffset + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }
                final date = DateTime(
                    _focusedMonth.year, _focusedMonth.month, day);
                final isToday = date.year == _today.year &&
                    date.month == _today.month &&
                    date.day == _today.day;
                final isTet = date.year == widget.tetDate.year &&
                    date.month == widget.tetDate.month &&
                    date.day == widget.tetDate.day;

                return Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isTet
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isTet || isToday
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isTet
                              ? Colors.white
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
