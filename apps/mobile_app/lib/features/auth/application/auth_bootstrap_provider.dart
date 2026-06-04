import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/application/auth_state_provider.dart';

final authBootstrapProvider = FutureProvider<bool>((ref) async {
  final authController = ref.watch(authControllerProvider);
  final user = await authController.currentUser();
  return user != null;
});
