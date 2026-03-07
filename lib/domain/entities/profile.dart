enum UserRole { user, admin }

class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final UserRole role;

  const Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.role = UserRole.user,
  });

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().toList();
    return parts.isEmpty ? 'Người dùng' : parts.join(' ');
  }
}
