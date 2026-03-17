import 'dart:typed_data';
import '../../../models/profile.dart';
import '../../interfaces/api/i_profile_service.dart';
import '../../interfaces/repositories/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileService _service;

  ProfileRepositoryImpl(this._service);

  @override
  Future<Profile> getCurrentProfile() => _service.getCurrentProfile();

  @override
  Future<void> updateProfile(Profile profile) =>
      _service.updateProfile(profile);

  @override
  Future<String> uploadAvatar(Uint8List bytes, String fileName) =>
      _service.uploadAvatar(bytes, fileName);

  @override
  Future<void> logout() => _service.logout();
}
