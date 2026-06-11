import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app/router/app_router.dart';
import 'package:mobile_app/app/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp({String initialLocation = AppRoutes.home}) {
    final router = createAppRouter();
    router.go(initialLocation);

    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('NavigationShell', () {
    testWidgets('renders all four bottom nav labels', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows home placeholder by default', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Home placeholder 0'), findsOneWidget);
    });

    testWidgets('switches tabs via bottom navigation', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();

      expect(find.text('Search your health records...'), findsOneWidget);
      expect(find.text('Home placeholder 0'), findsNothing);
    });

    testWidgets('IndexedStack keeps offstage tab widgets alive', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Home placeholder 0'), findsOneWidget);

      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();

      // Records is visible; home branch remains mounted offstage.
      expect(find.text('Search your health records...'), findsOneWidget);
      expect(
        find.text('Home placeholder 0', skipOffstage: false),
        findsOneWidget,
      );

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();

      expect(find.text('Upload placeholder'), findsOneWidget);
      expect(
        find.text('Home placeholder 0', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Search your health records...', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('deep link opens records tab', (tester) async {
      await tester.pumpWidget(buildApp(initialLocation: AppRoutes.records));
      await tester.pumpAndSettle();

      expect(find.text('Search your health records...'), findsOneWidget);
      expect(find.text('Home placeholder 0'), findsNothing);
    });
  });

  group('AppRoutes', () {
    test('branch indices map to shell tabs', () {
      expect(AppRoutes.branchIndexForPath(AppRoutes.home), 0);
      expect(AppRoutes.branchIndexForPath(AppRoutes.records), 1);
      expect(AppRoutes.branchIndexForPath(AppRoutes.upload), 2);
      expect(AppRoutes.branchIndexForPath(AppRoutes.settings), 3);
    });
  });
}
