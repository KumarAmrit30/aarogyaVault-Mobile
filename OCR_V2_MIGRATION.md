# OCR v2 Flutter Migration

This document describes how the Flutter mobile app reads OCR results from the
v2 backend pipeline (Document AI OCR + Gemini medical analysis) while remaining
compatible with legacy v1 records.

## Firestore schema

Collection: `ocr_results/{documentId}`

### v1 (legacy Gemini OCR)

Written when `USE_DOCUMENT_AI_OCR` is disabled or during rollback.

| Field | Type | Required |
|-------|------|----------|
| `documentId` | string | yes |
| `extractedText` | string | yes (inline full text) |
| `summary` | string | yes |
| `createdAt` | timestamp | yes |

### v2 (Document AI + medical analysis)

| Field | Type | Required |
|-------|------|----------|
| `documentId` | string | yes |
| `summary` | string | yes |
| `createdAt` | timestamp | yes |
| `processingVersion` | int (`2`) | yes |
| `ocrProvider` | string | yes |
| `documentType` | string | yes |
| `ocrTextPath` | string | yes |
| `ocrCharacterCount` | int | yes |
| `criticalFindings` | array | yes (may be empty) |
| `normalFindings` | string[] | yes (may be empty) |
| `recommendedFollowUp` | string[] | yes (may be empty) |
| `ocrConfidence` | number | optional |
| `pageCount` | int | optional |
| `handwritingDetected` | bool | optional |
| `extractionWarning` | string | optional |

**v2 does not write `extractedText` to Firestore.** Full OCR text is stored at:

```
ocr-results/{documentId}/full_text.txt
```

## Flutter data layer

### Domain

- `lib/features/ocr/domain/entities/ocr_result.dart` — unified entity for v1/v2
- `lib/features/ocr/domain/entities/critical_finding.dart` — finding + status enum

Entity helpers:

| Getter | Meaning |
|--------|---------|
| `isLegacyRecord` | `processingVersion` is null or `< 2` |
| `isAnalyzedRecord` | `processingVersion == 2` |
| `isStorageBacked` | `ocrTextPath` is set |
| `hasMedicalAnalysis` | findings, follow-up, or `documentType` present |
| `hasExtractionWarning` | non-empty `extractionWarning` |
| `isLowConfidence` | `ocrConfidence < 0.75` |

### Data

- `lib/features/ocr/data/models/ocr_result_model.dart` — Firestore DTO (`fromMap`, `toMap`, `toEntity`)
- `lib/features/ocr/data/models/critical_finding_model.dart` — nested finding DTO
- `lib/features/ocr/data/mappers/ocr_result_mapper.dart` — thin delegate over `OcrResultModel`
- `lib/features/ocr/data/repositories/firestore_ocr_repository.dart` — loads Firestore + Storage text

### Backward compatibility

1. **v1 records** — `extractedText` is read directly from Firestore; analysis lists default to empty.
2. **v2 records** — `OcrResultModel.mapRequiresStorageTextLoad()` triggers a Storage fetch in the repository; resolved text is passed to `toEntity(resolvedExtractedText: ...)`.
3. **Partial v2 metadata on old app versions** — extra Firestore fields are ignored by older clients; new clients parse them safely with type checks and empty-list defaults.
4. **Invalid finding entries** — skipped during `criticalFindings` parsing rather than failing the whole record.

## Riverpod providers

Defined in `lib/features/ocr/application/ocr_providers.dart`:

| Provider | Type | Purpose |
|----------|------|---------|
| `ocrRepositoryProvider` | `Provider<OcrRepository>` | Firestore + Storage repository |
| `ocrControllerProvider` | `Provider<OcrController>` | Domain controller |
| `ocrResultProvider` | `StreamProvider.family<OcrResult?, String>` | Live OCR result; `null` while processing |
| `ocrResultFutureProvider` | `FutureProvider.family<OcrResult?, String>` | One-shot fetch |
| `ocrIsProcessingProvider` | `Provider.family<bool, String>` | `true` when no `ocr_results` doc yet |
| `ocrIsV2Provider` | `Provider.family<bool, String>` | `true` for analyzed v2 records |
| `ocrHasExtractionWarningProvider` | `Provider.family<bool, String>` | `true` when manual verification is advised |

`ocr_state_provider.dart` re-exports `ocr_providers.dart` for backward-compatible imports.

### Example (future UI)

```dart
final async = ref.watch(ocrResultProvider(documentId));

return async.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (result) {
    if (result == null) {
      return const Text('Processing document…');
    }
    if (result.hasExtractionWarning) {
      return Banner(message: result.extractionWarning!);
    }
    return Column(
      children: [
        Text(result.summary),
        if (result.isAnalyzedRecord) ...[
          Text(result.documentType ?? 'Medical document'),
          ...result.criticalFindings.map((f) => Text(f.title)),
        ],
      ],
    );
  },
);
```

## Tests

Unit tests under `apps/mobile_app/test/features/ocr/`:

- `critical_finding_model_test.dart`
- `ocr_result_model_test.dart`
- `ocr_result_mapper_test.dart`
- `ocr_result_entity_test.dart`

Run:

```bash
cd apps/mobile_app && flutter test test/features/ocr/
```

## UI status

No presentation-layer screens were added in this migration. The data layer and
providers are ready for document detail, insights, and library screens.

## Related backend docs

- `docs/document-ai-setup.md` — Document AI processor setup
- `backend/functions/src/services/ocr_result_store.ts` — authoritative write schema
