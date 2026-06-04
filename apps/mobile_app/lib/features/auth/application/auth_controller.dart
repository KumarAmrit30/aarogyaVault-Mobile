import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/services/auth_service.dart';

class AuthController {
  AuthController(this._authRepository, this._authService);

  final AuthRepository _authRepository;
  final AuthService _authService;

  Future<void> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Stream<AuthUser?> authStateChanges() {
    return _authRepository.authStateChanges();
  }

  Future<AuthUser?> currentUser() {
    return _authRepository.getCurrentUser();
  }
}
