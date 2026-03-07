import '../../../domain/entities/profile.dart';

/// API layer interface for user profile.
/// Implement với Supabase Auth khi phát triển API thật.
abstract class IProfileService {
  Future<Profile> getCurrentProfile();
  Future<void> updateProfile(Profile profile);
  Future<void> logout();
}
