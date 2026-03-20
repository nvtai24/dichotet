// Dependency Injection
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/implementations/api/supabase_shopping_service.dart';
import 'data/implementations/api/supabase_profile_service.dart';
import 'data/implementations/api/supabase_auth_service.dart';
import 'data/implementations/api/supabase_session_service.dart';
import 'data/implementations/api/supabase_budget_service.dart';
import 'data/implementations/repositories/shopping_repository_impl.dart';
import 'data/implementations/repositories/profile_repository_impl.dart';
import 'data/implementations/repositories/auth_repository_impl.dart';
import 'data/implementations/repositories/session_repository_impl.dart';
import 'data/implementations/repositories/budget_repository_impl.dart';
import 'data/interfaces/api/i_shopping_service.dart';
import 'data/interfaces/api/i_profile_service.dart';
import 'data/interfaces/api/i_auth_service.dart';
import 'data/interfaces/api/i_session_service.dart';
import 'data/interfaces/api/i_budget_service.dart';
import 'data/interfaces/repositories/i_shopping_repository.dart';
import 'data/interfaces/repositories/i_profile_repository.dart';
import 'data/interfaces/repositories/i_auth_repository.dart';
import 'data/interfaces/repositories/i_session_repository.dart';
import 'data/interfaces/repositories/i_budget_repository.dart';
import 'data/local/local_cache_service.dart';

SupabaseClient get supabase => Supabase.instance.client;

// ─── Local cache ──────────────────────────────────────────────────────
final LocalCacheService localCacheService = LocalCacheService();

// ─── Services (API layer) ─────────────────────────────────────────────
final IShoppingService shoppingService = SupabaseShoppingService(supabase);
final IProfileService profileService = SupabaseProfileService(supabase);
final IAuthService authService = SupabaseAuthService(supabase);
final ISessionService sessionService = SupabaseSessionService(supabase);
final IBudgetService budgetService = SupabaseBudgetService(supabase);

// ─── Repositories ─────────────────────────────────────────────────────
final IShoppingRepository shoppingRepository = ShoppingRepositoryImpl(
  shoppingService,
  localCacheService,
);
final IProfileRepository profileRepository = ProfileRepositoryImpl(
  profileService,
);
final IAuthRepository authRepository = AuthRepositoryImpl(authService, localCacheService);
final ISessionRepository sessionRepository = SessionRepositoryImpl(
  sessionService,
  localCacheService,
);
final IBudgetRepository budgetRepository = BudgetRepositoryImpl(budgetService);
