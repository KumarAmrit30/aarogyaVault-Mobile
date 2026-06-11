import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/app/router/app_routes.dart';
import 'package:mobile_app/app/router/navigation_shell.dart';
import 'package:mobile_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/records/presentation/screens/record_detail_screen.dart';
import 'package:mobile_app/features/records/presentation/screens/records_screen.dart';
import 'package:mobile_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:mobile_app/features/upload/presentation/screens/upload_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Builds the application [GoRouter] with a tab shell and deep-linkable paths.
GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.records,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: RecordsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':documentId',
                    pageBuilder: (context, state) {
                      final documentId =
                          state.pathParameters['documentId']!;
                      return MaterialPage<void>(
                        child: RecordDetailScreen(documentId: documentId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.upload,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: UploadScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Global router used by [main.dart] and tests.
final GoRouter appRouter = createAppRouter();
