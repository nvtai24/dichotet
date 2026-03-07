import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'di.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'viewmodels/shopping/shopping_list_viewmodel.dart';
import 'viewmodels/home/dashboard_viewmodel.dart';
import 'viewmodels/budget/budget_viewmodel.dart';
import 'viewmodels/settings/settings_viewmodel.dart';
import 'views/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const DichotetApp());
}

class DichotetApp extends StatelessWidget {
  const DichotetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => ShoppingListViewModel(shoppingRepository)..loadData(),
        ),
        ChangeNotifierProxyProvider<ShoppingListViewModel, DashboardViewModel>(
          create: (ctx) =>
              DashboardViewModel(ctx.read<ShoppingListViewModel>()),
          update: (_, shoppingVM, prev) =>
              prev ?? DashboardViewModel(shoppingVM),
        ),
        ChangeNotifierProxyProvider<ShoppingListViewModel, BudgetViewModel>(
          create: (ctx) => BudgetViewModel(ctx.read<ShoppingListViewModel>()),
          update: (_, shoppingVM, prev) => prev ?? BudgetViewModel(shoppingVM),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(profileRepository)..loadProfile(),
        ),
      ],
      child: MaterialApp(
        title: 'Đi chợ Tết',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
