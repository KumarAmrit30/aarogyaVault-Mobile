import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/document/application/document_state_provider.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';
import 'package:mobile_app/features/ocr/application/ocr_providers.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/records/presentation/screens/records_screen.dart';
import 'package:mobile_app/shared/widgets/app_loading_indicator.dart';

void main() {
  final now = DateTime.utc(2026, 6, 11, 12);

  AppDocument sampleDoc({
    required String id,
    DocumentType type = DocumentType.labReport,
  }) {
    return AppDocument(
      id: id,
      ownerId: 'user-1',
      fileName: 'Blood_Report.pdf',
      documentType: type,
      storagePath: 'documents/user-1/$id.pdf',
      downloadUrl: 'https://example.com/$id.pdf',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  Widget buildScreen({
    required Stream<List<AppDocument>> documentsStream,
    OcrResult? ocrResult,
    String documentId = 'doc-1',
  }) {
    return ProviderScope(
      overrides: [
        userDocumentsProvider.overrideWith((ref) => documentsStream),
        ocrResultProvider(documentId).overrideWith(
          (ref) => Stream.value(ocrResult),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const RecordsScreen(),
      ),
    );
  }

  group('RecordsScreen', () {
    testWidgets('shows search bar and category chips', (tester) async {
      final controller = StreamController<List<AppDocument>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        buildScreen(documentsStream: controller.stream),
      );
      await tester.pump();

      expect(find.text('Search your health records...'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Prescriptions'), findsOneWidget);
      expect(find.text('Lab Reports'), findsOneWidget);
    });

    testWidgets('shows loading skeletons', (tester) async {
      final controller = StreamController<List<AppDocument>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        buildScreen(documentsStream: controller.stream),
      );
      await tester.pump();

      expect(find.byType(AppSkeletonCard), findsWidgets);
    });

    testWidgets('shows empty state when no documents', (tester) async {
      await tester.pumpWidget(
        buildScreen(documentsStream: Stream.value([])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your library is empty'), findsOneWidget);
      expect(find.text('Add New Record'), findsOneWidget);
    });

    testWidgets('shows document card with metadata', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          documentsStream: Stream.value([sampleDoc(id: 'doc-1')]),
          ocrResult: OcrResult(
            documentId: 'doc-1',
            extractedText: 'text',
            summary: 'summary',
            createdAt: now,
            processingVersion: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Blood_Report'), findsOneWidget);
      expect(find.text('Lab Report • Jun 11, 2026'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('shows error state with retry', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          documentsStream: Stream<List<AppDocument>>.error(
            Exception('Network error'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load records'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
