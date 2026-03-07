import 'package:flutter/foundation.dart';
import '../../data/interfaces/repositories/i_profile_repository.dart';
import '../../domain/entities/profile.dart';

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
}
