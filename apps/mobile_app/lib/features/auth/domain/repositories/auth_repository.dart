import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();

  Stream<AuthUser?> authStateChanges();

  Future<void> signOut();
}
