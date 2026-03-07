import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/interfaces/repositories/i_auth_repository.dart';
import '../../domain/entities/profile.dart';

class AuthViewModel extends ChangeNotifier {
  final IAuthRepository _repository;

  AuthViewModel(this._repository);

  // ─── State ──────────────────────────────────────────────────────────

  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool get isLoggedIn => _repository.isLoggedIn;

  // ─── Sign Up ──────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _profile = await _repository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _error = null;

    try {
      _profile = await _repository.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      _profile = null;
      notifyListeners();
    } catch (_) {
      // Vẫn clear local state dù API lỗi
      _profile = null;
      notifyListeners();
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────

  Future<bool> sendPasswordReset({required String email}) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.sendPasswordReset(email: email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Check current session ────────────────────────────────────────

  Future<void> checkCurrentUser() async {
    _profile = await _repository.getCurrentUser();
    notifyListeners();
  }

  // ─── Clear error ──────────────────────────────────────────────────

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Helper ───────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
