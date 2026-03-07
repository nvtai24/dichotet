// Dependency Injection
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/implementations/api/mock_shopping_service.dart';
import 'data/implementations/api/mock_profile_service.dart';
import 'data/implementations/api/supabase_auth_service.dart';
import 'data/implementations/repositories/shopping_repository_impl.dart';
import 'data/implementations/repositories/profile_repository_impl.dart';
import 'data/implementations/repositories/auth_repository_impl.dart';
import 'data/interfaces/api/i_shopping_service.dart';
import 'data/interfaces/api/i_profile_service.dart';
import 'data/interfaces/api/i_auth_service.dart';
import 'data/interfaces/repositories/i_shopping_repository.dart';
import 'data/interfaces/repositories/i_profile_repository.dart';
import 'data/interfaces/repositories/i_auth_repository.dart';

SupabaseClient get supabase => Supabase.instance.client;

// ─── Services (API layer) ─────────────────────────────────────────────
// Khi có API Supabase thật, thay MockXxxService bằng SupabaseXxxService.
final IShoppingService shoppingService = MockShoppingService();
final IProfileService profileService = MockProfileService();
final IAuthService authService = SupabaseAuthService(supabase);

// ─── Repositories ─────────────────────────────────────────────────────
final IShoppingRepository shoppingRepository = ShoppingRepositoryImpl(
  shoppingService,
);
final IProfileRepository profileRepository = ProfileRepositoryImpl(
  profileService,
);
final IAuthRepository authRepository = AuthRepositoryImpl(authService);
