import 'dart:typed_data';
import '../../../models/profile.dart';

abstract class IProfileRepository {
  Future<Profile> getCurrentProfile();
  Future<void> updateProfile(Profile profile);
  Future<String> uploadAvatar(Uint8List bytes, String fileName);
  Future<void> logout();
}
