import 'dart:typed_data';
import '../../../models/profile.dart';

/// API layer interface for user profile.
/// Implement với Supabase Auth khi phát triển API thật.
abstract class IProfileService {
  Future<Profile> getCurrentProfile();
  Future<void> updateProfile(Profile profile);
  Future<String> uploadAvatar(Uint8List bytes, String fileName);
  Future<void> logout();
}
