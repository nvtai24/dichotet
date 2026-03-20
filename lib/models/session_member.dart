class SessionMember {
  final String id;
  final String sessionId;
  final String userId;
  final String role; // 'owner' | 'member'
  final DateTime joinedAt;
  final String? displayName;
  final String? email;

  SessionMember({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.displayName,
    this.email,
  });

  bool get isOwner => role == 'owner';
}
