import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/providers/firebase_providers.dart';
import 'package:mobile_app/features/auth/application/auth_providers.dart';
import 'package:mobile_app/features/user/data/repositories/firestore_user_repository.dart';
import 'package:mobile_app/features/user/data/services/firestore_user_service.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';
import 'package:mobile_app/features/user/domain/services/user_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreUserRepository(firestore);
});

final userServiceProvider = Provider<UserService>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return FirestoreUserService(userRepository, authRepository);
});
