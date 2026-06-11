# Record Library Implementation

Stitch Record Library screen at `/records`, connected to live Firebase document and OCR data.

## Data flow

```
Firestore documents/{id}
        │
        ▼
DocumentRepository.watchUserDocuments(userId)
        │
        ▼
DocumentController.watchDocuments()
        │
        ▼
userDocumentsProvider (StreamProvider)
        │
        ▼
filteredDocumentsProvider (category filter + sort)
        │
        ▼
RecordsScreen → RecordCard (per document)

Firestore ocr_results/{documentId}
        │
        ▼
OcrRepository.watchOcrResult(documentId)
        │
        ▼
ocrResultProvider(documentId) (StreamProvider.family)
        │
        ▼
recordProcessingStatusProvider(documentId)
        │
        ▼
RecordCard status badge + action label
```

## Provider usage

| Provider | Type | Role |
|----------|------|------|
| `userDocumentsProvider` | `StreamProvider<List<AppDocument>>` | Live user document list from Firestore |
| `recordCategoryFilterProvider` | `NotifierProvider<RecordCategoryFilter>` | Selected chip: All / Prescriptions / Lab Reports |
| `filteredDocumentsProvider` | `Provider<AsyncValue<List<AppDocument>>>` | Filtered + sorted (newest first) list |
| `ocrResultProvider(documentId)` | `StreamProvider.family<OcrResult?, String>` | Per-document OCR stream |
| `recordProcessingStatusProvider(documentId)` | `Provider.family<RecordProcessingStatus, String>` | Card badge: PENDING / VERIFIED |

### Processing status rules

| Condition | Status | Badge | Action |
|-----------|--------|-------|--------|
| No `ocr_results` doc yet | `processing` | PENDING | Track Status |
| OCR stream loading | `processing` | PENDING | Track Status |
| `hasExtractionWarning` | `pending` | PENDING | Track Status |
| OCR result present | `verified` | VERIFIED | View Details |
| OCR stream error | `pending` | PENDING | Track Status |

## State handling

| UI state | Trigger | Component |
|----------|---------|-----------|
| **Loading** | `filteredDocumentsProvider` is loading | `AppSkeletonCard` × 3 |
| **Empty** | Filtered list is empty | `AppEmptyState` (dashed border) + "Add New Record" → `/upload` |
| **Error** | `userDocumentsProvider` error | `AppEmptyState` + "Try Again" (invalidates provider) |
| **Data** | Non-empty list | `RecordCard` list |
| **Refresh** | Pull-to-refresh | `RefreshIndicator` → `ref.invalidate(userDocumentsProvider)` |

### Visual-only (not wired yet)

- Search bar (`AppTextField`, `readOnly: true`)
- Header search icon (`onPressed: null`)
- "Newest First" sort toggle (list is always sorted newest first)

## Screen layout (Stitch)

1. **Header** — avatar, "Aarogya Vault" title, search icon
2. **Search** — `AppTextField` with magnifying glass
3. **Chips** — `RecordCategoryChips`
4. **Sort label** — "Newest First" + icon
5. **List** — `RecordCard` per document
6. **FAB** — navigates to `/upload`
7. **Bottom nav** — provided by `NavigationShell`

### Record card fields

- **Title** — file name without extension
- **Document type** — `DocumentType.displayName`
- **Upload date** — `createdAt` formatted (`Oct 28, 2023`)
- **Processing status** — VERIFIED / PENDING badge from OCR
- **Action** — "View Details" or "Track Status"

## Navigation

| Action | Route |
|--------|-------|
| Tap record card | `context.push('/records/:documentId')` |
| FAB / Add New Record | `context.go('/upload')` |

`RecordDetailScreen` is a placeholder at `/records/:documentId` until the Stitch detail screen is implemented.

## Files

```
lib/features/records/
├── application/
│   └── records_providers.dart
├── domain/enums/
│   ├── record_category_filter.dart
│   └── record_processing_status.dart
└── presentation/
    ├── screens/
    │   ├── records_screen.dart
    │   └── record_detail_screen.dart
    ├── widgets/
    │   ├── record_card.dart
    │   └── record_category_chips.dart
    └── utils/
        └── record_formatters.dart

lib/features/document/domain/extensions/
└── document_type_display.dart
```

## Tests

```bash
cd apps/mobile_app
flutter analyze
flutter test
```

- `test/features/records/records_providers_test.dart` — status resolution, filter default
- `test/features/records/records_screen_test.dart` — loading, empty, data, error UI
- `test/app/router/navigation_shell_test.dart` — updated for records screen
