import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/services/auth_service.dart';
import 'package:mobile_app/features/user/domain/services/user_service.dart';

class AuthController {
  AuthController(
    this._authRepository,
    this._authService,
    this._userService,
  );

  final AuthRepository _authRepository;
  final AuthService _authService;
  final UserService _userService;

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
    await _userService.createUserIfNotExists();
    await _userService.updateLastLogin();
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
