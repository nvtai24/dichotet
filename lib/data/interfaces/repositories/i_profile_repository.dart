import '../../../domain/entities/profile.dart';

abstract class IProfileRepository {
  Future<Profile> getCurrentProfile();
  Future<void> updateProfile(Profile profile);
  Future<void> logout();
}
