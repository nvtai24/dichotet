import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/profile.dart';
import '../../interfaces/api/i_profile_service.dart';

class SupabaseProfileService implements IProfileService {
  final SupabaseClient _client;

  SupabaseProfileService(this._client);

  @override
  Future<Profile> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return Profile(
      id: data['id'] as String,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?,
      email: user.email,
      phone: data['phone'] as String?,
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update({
          'first_name': profile.firstName,
          'last_name': profile.lastName,
          'phone': profile.phone,
        })
        .eq('id', profile.id);
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
