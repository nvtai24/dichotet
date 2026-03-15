import '../../../models/profile.dart';

abstract class IAuthRepository {
  Future<Profile> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  });

  Future<Profile> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordReset({required String email});

  Future<void> updatePassword({required String newPassword});

  Future<Profile?> getCurrentUser();

  Future<Profile> signInWithGoogle();

  bool get isLoggedIn;
}
