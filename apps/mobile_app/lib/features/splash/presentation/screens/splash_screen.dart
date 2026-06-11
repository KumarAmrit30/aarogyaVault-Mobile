import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/application/auth_bootstrap_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authBootstrapProvider, (previous, next) {
      next.whenData((isAuthenticated) {
        if (!context.mounted) {
          return;
        }
        if (isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      });
    });

    final authBootstrap = ref.watch(authBootstrapProvider);

    return Scaffold(
      body: Center(
        child: authBootstrap.when(
          loading: () => const CircularProgressIndicator(),
          error: (_, _) => const CircularProgressIndicator(),
          data: (_) => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
