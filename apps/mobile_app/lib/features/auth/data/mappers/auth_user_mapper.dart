import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';

extension AuthUserMapper on User {
  AuthUser toAuthUser() {
    return AuthUser(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoURL,
    );
  }
}
