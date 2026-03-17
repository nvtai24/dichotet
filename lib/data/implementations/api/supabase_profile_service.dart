import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/profile.dart';
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
      imageUrl: data['image_url'] as String?,
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
          'image_url': profile.imageUrl,
        })
        .eq('id', profile.id);
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes, String fileName) async {
    final path = 'avatars/$fileName';
    await _client.storage
        .from('avatars')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
