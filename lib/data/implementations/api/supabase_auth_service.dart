import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/profile.dart';
import '../../interfaces/api/i_auth_service.dart';

class SupabaseAuthService implements IAuthService {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  // ─── Sign Up ──────────────────────────────────────────────────────

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
      },
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Đăng ký không thành công. Vui lòng thử lại.');
    }

    return _mapUser(user);
  }

  // ─── Sign In ──────────────────────────────────────────────────────

  @override
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Đăng nhập không thành công.');
    }

    return _mapUser(user);
  }

  // ─── Sign Out ─────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Password Reset ───────────────────────────────────────────────

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ─── Current User ─────────────────────────────────────────────────

  @override
  Future<Profile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  bool get isLoggedIn => _client.auth.currentUser != null;

  // ─── Helper ───────────────────────────────────────────────────────

  Profile _mapUser(User user) {
    final meta = user.userMetadata ?? {};
    return Profile(
      id: user.id,
      firstName: meta['first_name'] as String?,
      lastName: meta['last_name'] as String?,
      email: user.email,
      avatarUrl: meta['avatar_url'] as String?,
    );
  }
}
