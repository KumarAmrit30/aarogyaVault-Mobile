import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/app/router/app_router.dart';

/// Riverpod-managed GoRouter instance for the application.
final goRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});
