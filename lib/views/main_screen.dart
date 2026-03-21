import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/session/session_viewmodel.dart';
import '../viewmodels/shopping/shopping_list_viewmodel.dart';
import 'home/dashboard_screen.dart';
import 'shopping_list/shopping_list_screen.dart';
import 'shopping_list/add_item_screen.dart';
import 'budget/budget_screen.dart';
import 'settings/settings_screen.dart';
import 'session/session_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().addListener(_onSessionChanged);
    });
  }

  @override
  void dispose() {
    context.read<SessionViewModel>().removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    final sessionVM = context.read<SessionViewModel>();
    if (sessionVM.kickedFromSessionId != null) {
      final wasDeleted = sessionVM.sessionWasDeleted;
      sessionVM.clearKicked();
      context.read<ShoppingListViewModel>().reset();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasDeleted
                ? 'Phiên mua sắm đã bị xóa'
                : 'Bạn đã bị xóa khỏi phiên mua sắm',
          ),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SessionListScreen()),
        (route) => false,
      );
    }
  }

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    ShoppingListScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Trang chủ'),
    (Icons.list_alt_outlined, Icons.list_alt_rounded, 'Danh sách'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'Ngân sách',
    ),
    (Icons.settings_outlined, Icons.settings_rounded, 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      elevation: 12,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Left 2 items
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [0, 1]
                  .map(
                    (i) => _NavItem(
                      icon: _items[i].$1,
                      activeIcon: _items[i].$2,
                      label: _items[i].$3,
                      isActive: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Center gap for FAB
          const SizedBox(width: 72),
          // Right 2 items
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 3]
                  .map(
                    (i) => _NavItem(
                      icon: _items[i].$1,
                      activeIcon: _items[i].$2,
                      label: _items[i].$3,
                      isActive: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
