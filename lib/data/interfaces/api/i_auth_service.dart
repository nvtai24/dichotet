import '../../../domain/entities/profile.dart';

abstract class IAuthService {
  /// Đăng ký tài khoản mới bằng email + password.
  /// Trả về [Profile] nếu thành công.
  Future<Profile> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  });

  /// Đăng nhập bằng email + password.
  Future<Profile> signIn({required String email, required String password});

  /// Đăng xuất.
  Future<void> signOut();

  /// Gửi email reset password.
  Future<void> sendPasswordReset({required String email});

  /// Trả về profile của user hiện tại (nếu đã đăng nhập), hoặc `null`.
  Future<Profile?> getCurrentUser();

  /// Kiểm tra nhanh user đã đăng nhập chưa.
  bool get isLoggedIn;
}
