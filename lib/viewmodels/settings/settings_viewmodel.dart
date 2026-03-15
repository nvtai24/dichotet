import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/i_profile_repository.dart';
import '../../models/profile.dart';

class SettingsViewModel extends ChangeNotifier {
  final IProfileRepository _repository;

  SettingsViewModel(this._repository);

  // ─── State ──────────────────────────────────────────────────────────

  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String get userName => _profile?.fullName ?? 'Người dùng';
  String get userEmail => _profile?.email ?? '';
  String get userPhone => _profile?.phone ?? '';

  // ─── Actions ────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getCurrentProfile();
    } catch (_) {
      // Silently handle for now
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  // ─── Update Profile ─────────────────────────────────────────────────

  Future<bool> updateName({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = Profile(
        id: _profile!.id,
        firstName: firstName,
        lastName: lastName,
        email: _profile!.email,
        phone: phone ?? _profile!.phone,
      );
      await _repository.updateProfile(updated);
      _profile = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
