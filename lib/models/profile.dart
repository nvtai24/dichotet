class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? imageUrl;

  const Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.imageUrl,
  });

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().toList();
    return parts.isEmpty ? 'Người dùng' : parts.join(' ');
  }
}
