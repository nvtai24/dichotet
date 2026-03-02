enum UserRole { user, admin }

class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final UserRole role;

  const Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.role = UserRole.user,
  });
}
