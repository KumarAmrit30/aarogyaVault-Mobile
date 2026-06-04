class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
}
