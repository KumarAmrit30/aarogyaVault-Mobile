import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/user/domain/entities/app_user.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';
import 'package:mobile_app/features/user/domain/services/user_service.dart';

class FirestoreUserService implements UserService {
  FirestoreUserService(this._userRepository, this._authRepository);

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  @override
  Future<void> createUserIfNotExists() async {
    final authUser = await _authRepository.getCurrentUser();
    if (authUser == null) {
      return;
    }

    final existingUser = await _userRepository.getUser(authUser.id);
    if (existingUser != null) {
      return;
    }

    final now = DateTime.now();
    final appUser = AppUser(
      uid: authUser.id,
      email: authUser.email,
      displayName: authUser.displayName,
      photoUrl: authUser.photoUrl,
      createdAt: now,
      lastLoginAt: now,
      isActive: true,
    );

    await _userRepository.createUser(appUser);
  }

  @override
  Future<void> updateLastLogin() async {
    final authUser = await _authRepository.getCurrentUser();
    if (authUser == null) {
      return;
    }

    final existingUser = await _userRepository.getUser(authUser.id);
    if (existingUser == null) {
      return;
    }

    final updatedUser = AppUser(
      uid: existingUser.uid,
      email: existingUser.email,
      displayName: existingUser.displayName,
      photoUrl: existingUser.photoUrl,
      createdAt: existingUser.createdAt,
      lastLoginAt: DateTime.now(),
      isActive: existingUser.isActive,
    );

    await _userRepository.updateUser(updatedUser);
  }
}
