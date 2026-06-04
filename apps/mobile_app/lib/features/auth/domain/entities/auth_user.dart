class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
}
