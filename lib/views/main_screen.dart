import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'home/dashboard_screen.dart';
import 'shopping_list/shopping_list_screen.dart';
import 'shopping_list/add_item_screen.dart';
import 'budget/budget_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

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
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
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
