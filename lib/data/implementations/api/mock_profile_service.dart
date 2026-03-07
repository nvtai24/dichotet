import '../../../domain/entities/profile.dart';
import '../../interfaces/api/i_profile_service.dart';

/// Mock implementation – trả dữ liệu người dùng giả.
/// Khi có Supabase Auth, tạo SupabaseProfileService gọi
/// supabase.auth.currentUser, supabase.from('profiles')...
class MockProfileService implements IProfileService {
  Profile _profile = const Profile(
    id: 'mock-user-001',
    firstName: 'Nguyễn',
    lastName: 'Văn A',
    email: 'nguyenvana@email.com',
    role: UserRole.user,
  );

  @override
  Future<Profile> getCurrentProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _profile;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profile = profile;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock logout — không làm gì
  }
}
