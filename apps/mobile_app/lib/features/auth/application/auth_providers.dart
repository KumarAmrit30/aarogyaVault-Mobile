import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/providers/firebase_providers.dart';
import 'package:mobile_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:mobile_app/features/auth/data/services/google_auth_service.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return GoogleAuthService(firebaseAuth);
});
