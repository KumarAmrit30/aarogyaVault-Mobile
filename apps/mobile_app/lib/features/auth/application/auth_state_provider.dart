import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/application/auth_controller.dart';
import 'package:mobile_app/features/auth/application/auth_providers.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/user/application/user_providers.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);
  return AuthController(authRepository, authService, userService);
});

final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.authStateChanges();
});
