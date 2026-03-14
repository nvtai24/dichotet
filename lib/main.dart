import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'di.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'viewmodels/session/session_viewmodel.dart';
import 'viewmodels/shopping/shopping_list_viewmodel.dart';
import 'viewmodels/home/dashboard_viewmodel.dart';
import 'viewmodels/budget/budget_viewmodel.dart';
import 'viewmodels/settings/settings_viewmodel.dart';
import 'views/auth/reset_password_screen.dart';
import 'views/splash/splash_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const DichotetApp());
}

class DichotetApp extends StatefulWidget {
  const DichotetApp({super.key});

  @override
  State<DichotetApp> createState() => _DichotetAppState();
}

class _DichotetAppState extends State<DichotetApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Lắng nghe auth event từ Supabase deep link
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        // User click link reset password → mở màn hình đặt mật khẩu mới
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => SessionViewModel(sessionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ShoppingListViewModel(shoppingRepository),
        ),
        ChangeNotifierProxyProvider2<
          ShoppingListViewModel,
          SessionViewModel,
          DashboardViewModel
        >(
          create: (ctx) => DashboardViewModel(
            ctx.read<ShoppingListViewModel>(),
            ctx.read<SessionViewModel>(),
          ),
          update: (_, shoppingVM, sessionVM, prev) =>
              prev ?? DashboardViewModel(shoppingVM, sessionVM),
        ),
        ChangeNotifierProxyProvider2<
          SessionViewModel,
          ShoppingListViewModel,
          BudgetViewModel
        >(
          create: (ctx) => BudgetViewModel(
            budgetRepository,
            ctx.read<SessionViewModel>(),
            ctx.read<ShoppingListViewModel>(),
          ),
          update: (_, sessionVM, shoppingVM, prev) =>
              prev ?? BudgetViewModel(budgetRepository, sessionVM, shoppingVM),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(profileRepository)..loadProfile(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Đi chợ Tết',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
