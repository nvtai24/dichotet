// Dependency Injection
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/implementations/api/supabase_shopping_service.dart';
import 'data/implementations/api/supabase_profile_service.dart';
import 'data/implementations/api/supabase_auth_service.dart';
import 'data/implementations/api/supabase_session_service.dart';
import 'data/implementations/repositories/shopping_repository_impl.dart';
import 'data/implementations/repositories/profile_repository_impl.dart';
import 'data/implementations/repositories/auth_repository_impl.dart';
import 'data/implementations/repositories/session_repository_impl.dart';
import 'data/interfaces/api/i_shopping_service.dart';
import 'data/interfaces/api/i_profile_service.dart';
import 'data/interfaces/api/i_auth_service.dart';
import 'data/interfaces/api/i_session_service.dart';
import 'data/interfaces/repositories/i_shopping_repository.dart';
import 'data/interfaces/repositories/i_profile_repository.dart';
import 'data/interfaces/repositories/i_auth_repository.dart';
import 'data/interfaces/repositories/i_session_repository.dart';

SupabaseClient get supabase => Supabase.instance.client;

// ─── Services (API layer) ─────────────────────────────────────────────
final IShoppingService shoppingService = SupabaseShoppingService(supabase);
final IProfileService profileService = SupabaseProfileService(supabase);
final IAuthService authService = SupabaseAuthService(supabase);
final ISessionService sessionService = SupabaseSessionService(supabase);

// ─── Repositories ─────────────────────────────────────────────────────
final IShoppingRepository shoppingRepository = ShoppingRepositoryImpl(
  shoppingService,
);
final IProfileRepository profileRepository = ProfileRepositoryImpl(
  profileService,
);
final IAuthRepository authRepository = AuthRepositoryImpl(authService);
final ISessionRepository sessionRepository = SessionRepositoryImpl(
  sessionService,
);
