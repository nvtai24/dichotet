import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/profile.dart';
import '../../interfaces/api/i_auth_service.dart';

class SupabaseAuthService implements IAuthService {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  static const _redirectUrl = 'com.example.dichotet://login-callback';

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
      emailRedirectTo: _redirectUrl,
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
    await _client.auth.resetPasswordForEmail(email, redirectTo: _redirectUrl);
  }

  // ─── Update Password ──────────────────────────────────────────────

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
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

  // ─── Google Sign-In ────────────────────────────────────────────────

  @override
  Future<Profile> signInWithGoogle() async {
    final webClientId =
        dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? 'YOUR_GOOGLE_WEB_CLIENT_ID';

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: webClientId);

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException {
      throw AuthException('Đăng nhập Google đã bị huỷ.');
    }

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw AuthException('Không lấy được token từ Google.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Đăng nhập Google không thành công.');
    }

    return _mapUser(user);
  }

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
