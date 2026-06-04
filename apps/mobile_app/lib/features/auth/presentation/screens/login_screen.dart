import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/features/auth/application/auth_state_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && context.mounted) {
          context.go('/dashboard');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: _SignInButton(
          onSignIn: ref.read(authControllerProvider).signInWithGoogle,
        ),
      ),
    );
  }
}

class _SignInButton extends StatefulWidget {
  const _SignInButton({required this.onSignIn});

  final Future<void> Function() onSignIn;

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await widget.onSignIn();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return ElevatedButton(
      onPressed: _handleSignIn,
      child: const Text('Continue with Google'),
    );
  }
}
