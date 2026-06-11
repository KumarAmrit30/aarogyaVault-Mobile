import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_card.dart';
import 'package:mobile_app/shared/widgets/app_empty_state.dart';
import 'package:mobile_app/shared/widgets/app_loading_indicator.dart';
import 'package:mobile_app/shared/widgets/app_text_field.dart';

Widget _wrap(Widget child, {bool dark = false}) {
  return MaterialApp(
    theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('renders primary label', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Retry Upload')),
      );
      expect(find.text('Retry Upload'), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Loading', isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppCard', () {
    testWidgets('renders child in elevated card', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppCard(child: Text('Card content'))),
      );
      expect(find.text('Card content'), findsOneWidget);
    });
  });

  group('AppTextField', () {
    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            hintText: 'Search your health records...',
          ),
        ),
      );
      expect(find.text('Search your health records...'), findsOneWidget);
    });
  });

  group('AppLoadingIndicator', () {
    testWidgets('renders circular variant', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppLoadingIndicator()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders skeleton variant', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppLoadingIndicator(
            variant: AppLoadingVariant.skeleton,
            skeletonLines: 2,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });
  });

  group('AppEmptyState', () {
    testWidgets('renders title and action', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            title: 'Your library is empty',
            subtitle: 'Search results and uploaded documents will appear here.',
            actionLabel: 'Add New Record',
            onAction: () {},
            icon: const Icon(Icons.folder_off_outlined),
          ),
        ),
      );
      expect(find.text('Your library is empty'), findsOneWidget);
      expect(find.text('Add New Record'), findsOneWidget);
    });
  });
}
