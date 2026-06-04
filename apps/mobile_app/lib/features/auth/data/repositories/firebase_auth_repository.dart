import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user?.toAuthUser();
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
          (user) => user?.toAuthUser(),
        );
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign out failed.');
    }
  }
}
