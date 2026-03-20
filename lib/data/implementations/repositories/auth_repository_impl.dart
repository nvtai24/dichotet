import '../../../models/profile.dart';
import '../../interfaces/api/i_auth_service.dart';
import '../../interfaces/repositories/i_auth_repository.dart';
import '../../local/local_cache_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthService _service;
  final LocalCacheService _cache;

  AuthRepositoryImpl(this._service, this._cache);

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) => _service.signUp(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
  );

  @override
  Future<Profile> signIn({required String email, required String password}) =>
      _service.signIn(email: email, password: password);

  @override
  Future<void> signOut() async {
    await _service.signOut();
    _cache.clear();
  }

  @override
  Future<void> sendPasswordReset({required String email}) =>
      _service.sendPasswordReset(email: email);

  @override
  Future<void> updatePassword({required String newPassword}) =>
      _service.updatePassword(newPassword: newPassword);

  @override
  Future<Profile?> getCurrentUser() => _service.getCurrentUser();

  @override
  Future<Profile> signInWithGoogle() => _service.signInWithGoogle();

  @override
  bool get isLoggedIn => _service.isLoggedIn;
}
