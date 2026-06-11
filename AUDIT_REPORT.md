# Aarogya Vault — Flutter Architecture Audit

**Date:** June 2026  
**Scope:** `apps/mobile_app/lib` (read-only inspection)  
**Purpose:** Pre-UI implementation audit before Stitch design implementation

No code was modified during this audit. All conclusions are based on files present in the repository.

---

## 1. Folder Structure

### 1.1 `lib/` Tree

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── providers/
│   │   ├── firebase_providers.dart      # Firebase singletons
│   │   └── network_providers.dart       # Dio (unused)
│   ├── router/
│   │   └── app_router.dart              # GoRouter (3 routes)
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   └── app_exception.dart
│   ├── services/
│   │   └── logger_service.dart          # UNUSED
│   ├── network/                           # EMPTY directory
│   ├── utils/                             # EMPTY directory
│   └── extensions/                        # EMPTY directory
└── features/
    ├── splash/presentation/screens/
    │   └── splash_screen.dart
    ├── auth/
    │   ├── application/                   # controllers, providers, state classes
    │   ├── data/                          # repositories, services, mappers
    │   ├── domain/                        # entities, repositories, services
    │   └── presentation/screens/
    │       └── login_screen.dart
    ├── user/
    │   ├── application/
    │   ├── data/
    │   └── domain/                        # NO presentation/
    ├── document/
    │   ├── application/
    │   ├── data/
    │   └── domain/                        # NO presentation/
    ├── ocr/
    │   ├── application/
    │   ├── data/
    │   └── domain/                        # NO presentation/
    └── dashboard/presentation/screens/
        └── dashboard_screen.dart          # Only non-auth presentation screen
```

### 1.2 Architecture Pattern

| Layer | Convention | Status |
|-------|------------|--------|
| `domain/` | Entities, repository interfaces, service interfaces | ✅ Consistent across features |
| `data/` | Repository impls, mappers, Firebase services | ✅ Consistent |
| `application/` | Controllers, Riverpod providers | ✅ Consistent |
| `presentation/` | Screens, widgets | ⚠️ Only 3 screens total; document/ocr/user have **no** presentation layer |

### 1.3 Features Without `presentation/`

| Feature | Data layer | UI |
|---------|------------|-----|
| `user` | Complete | **None** |
| `document` | Complete | Upload/delete embedded in `dashboard_screen.dart` only |
| `ocr` | Complete | **None** |

---

## 2. Screens Inventory

### 2.1 Existing Screens

| Screen | File | Route | Widget type |
|--------|------|-------|-------------|
| **Splash** | `features/splash/presentation/screens/splash_screen.dart` | `/` | `ConsumerWidget` |
| **Login** | `features/auth/presentation/screens/login_screen.dart` | `/login` | `ConsumerWidget` |
| **Dashboard** | `features/dashboard/presentation/screens/dashboard_screen.dart` | `/dashboard` | `ConsumerWidget` |

**Total screens: 3**

### 2.2 Requested Screens — Existence Check

| Screen | Exists? | Notes |
|--------|---------|-------|
| **Dashboard** | ✅ Yes | Basic list + upload FAB; no OCR status, no navigation to detail |
| **Library** | ❌ **Not found in repository** | No `library` feature folder or route. `DashboardScreen` currently serves as the document list (de facto library). |
| **Detail** | ❌ **Not found in repository** | No document detail route, screen, or `presentation/` under `document/` or `ocr/` |
| **Search** | ❌ **Not found in repository** | No search feature folder, provider, or screen |

### 2.3 Shared Widgets

**Not found in repository** — no `lib/shared/`, `lib/widgets/`, or `presentation/widgets/` directories.

---

## 3. GoRouter Audit

### 3.1 Configuration

**File:** `lib/app/router/app_router.dart`

```dart
GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',        → SplashScreen),
    GoRoute(path: '/login',    → LoginScreen),
    GoRoute(path: '/dashboard', → DashboardScreen),
  ],
)
```

### 3.2 Observations

| Item | Status |
|------|--------|
| Total routes | **3** |
| Path parameters (e.g. `/documents/:id`) | **Not found** |
| Named routes | **Not found** |
| `redirect` / auth guards | **Not found** — unauthenticated users can navigate to `/dashboard` manually |
| `ShellRoute` / bottom navigation | **Not found** |
| Deep linking config | **Not found** |
| Error / 404 route | **Not found** |

### 3.3 Navigation Calls (observed)

| From | To | Method |
|------|-----|--------|
| `SplashScreen` | `/dashboard` or `/login` | `context.go()` via `authBootstrapProvider` |
| `LoginScreen` | `/dashboard` | `context.go()` via `authStateChangesProvider` listener |

**No `context.push()` calls found** — no stack-based detail navigation exists yet.

---

## 4. Riverpod Providers Audit

### 4.1 Provider Inventory

| Provider | File | Type | Consumed by |
|----------|------|------|-------------|
| `firebaseAuthProvider` | `app/providers/firebase_providers.dart` | `Provider` | auth chain |
| `firestoreProvider` | `app/providers/firebase_providers.dart` | `Provider` | document, user, ocr repos |
| `firebaseStorageProvider` | `app/providers/firebase_providers.dart` | `Provider` | storage, ocr repos |
| `dioProvider` | `app/providers/network_providers.dart` | `Provider` | **UNUSED** |
| `authRepositoryProvider` | `auth/application/auth_providers.dart` | `Provider` | auth + document + user chain |
| `authServiceProvider` | `auth/application/auth_providers.dart` | `Provider` | auth controller |
| `authControllerProvider` | `auth/application/auth_state_provider.dart` | `Provider` | login, bootstrap, auth stream |
| `authStateChangesProvider` | `auth/application/auth_state_provider.dart` | `StreamProvider` | `LoginScreen` |
| `authBootstrapProvider` | `auth/application/auth_bootstrap_provider.dart` | `FutureProvider` | `SplashScreen` |
| `userRepositoryProvider` | `user/application/user_providers.dart` | `Provider` | user service only |
| `userServiceProvider` | `user/application/user_providers.dart` | `Provider` | auth controller only |
| `documentRepositoryProvider` | `document/application/document_providers.dart` | `Provider` | document service + controller |
| `storageServiceProvider` | `document/application/document_providers.dart` | `Provider` | document service |
| `documentServiceProvider` | `document/application/document_providers.dart` | `Provider` | document controller |
| `documentControllerProvider` | `document/application/document_state_provider.dart` | `Provider` | dashboard |
| `userDocumentsProvider` | `document/application/document_state_provider.dart` | `StreamProvider` | `DashboardScreen` |
| `ocrRepositoryProvider` | `ocr/application/ocr_providers.dart` | `Provider` | ocr controller |
| `ocrControllerProvider` | `ocr/application/ocr_state_provider.dart` | `Provider` | ocr result provider |
| `ocrResultProvider` | `ocr/application/ocr_state_provider.dart` | `StreamProvider.family` | **UNUSED in any screen** |

**Total providers: 19** (17 active in provider graph, 2 unused at UI layer)

### 4.2 Provider Dependency Graph

```
firebaseAuthProvider ──┬── authRepositoryProvider ──┬── authControllerProvider
                       │                           ├── documentServiceProvider
                       │                           └── userServiceProvider
                       └── authServiceProvider ────── authControllerProvider

firestoreProvider ──┬── documentRepositoryProvider ── documentServiceProvider
                      │                              └── documentControllerProvider
                      ├── userRepositoryProvider ── userServiceProvider
                      └── ocrRepositoryProvider ── ocrControllerProvider

firebaseStorageProvider ──┬── storageServiceProvider
                          └── ocrRepositoryProvider

userDocumentsProvider ← documentControllerProvider ← documentServiceProvider
ocrResultProvider ← ocrControllerProvider ← ocrRepositoryProvider  (no UI consumer)
```

### 4.3 Riverpod Code Generation

| Item | Status |
|------|--------|
| `@riverpod` annotations | **Not found in repository** |
| `riverpod_generator` in pubspec | Declared, **not used** |
| `riverpod_annotation` in pubspec | Declared, **not used** |

All providers are hand-written `Provider` / `StreamProvider` / `FutureProvider`.

---

## 5. Firebase Auth Flow

### 5.1 Flow Diagram

```
App start
  → main.dart: Firebase.initializeApp()
  → SplashScreen
      → authBootstrapProvider (FutureProvider)
          → authController.currentUser()
          → if authenticated → context.go('/dashboard')
          → else             → context.go('/login')

LoginScreen
  → user taps "Continue with Google"
      → authController.signInWithGoogle()
          → GoogleAuthService.signInWithGoogle()
              → GoogleSignIn.authenticate()
              → FirebaseAuth.signInWithCredential()
          → FirestoreUserService.createUserIfNotExists()
              → Firestore users/{uid} (if new)
          → FirestoreUserService.updateLastLogin()
      → authStateChangesProvider emits AuthUser
      → LoginScreen listener → context.go('/dashboard')
```

### 5.2 Auth Components

| Component | File | Role |
|-----------|------|------|
| `AuthService` | `GoogleAuthService` | Google Sign-In + Firebase credential |
| `AuthRepository` | `FirebaseAuthRepository` | `currentUser`, `authStateChanges`, `signOut` |
| `AuthController` | `auth_controller.dart` | Orchestrates sign-in + user bootstrap |
| `AuthUser` entity | `auth/domain/entities/auth_user.dart` | `id`, `email`, `displayName`, `photoUrl` |

### 5.3 Auth Gaps

| Gap | Evidence |
|-----|----------|
| Sign-out UI | `authController.signOut()` exists; **no screen calls it** |
| Route protection | No GoRouter `redirect`; `/dashboard` accessible without auth guard |
| Profile display | `AppUser` / `AuthUser` data never shown in UI |
| `userRepository.watchUser()` | Implemented; **no provider or screen consumes it** |
| Firebase App Check | `firebase_app_check` in pubspec; **not initialized in `main.dart`** |

---

## 6. Upload Flow

### 6.1 Flow Diagram

```
DashboardScreen._UploadFab
  → FilePicker.pickFiles(pdf, jpg, jpeg, png)
  → SimpleDialog: user selects DocumentType (7 options)
  → documentController.uploadDocument(file, documentType)
      → FirestoreDocumentService.uploadDocument()
          → authRepository.getCurrentUser() — throws if null
          → documentId = DateTime.now().millisecondsSinceEpoch
          → storagePath = documents/{userId}/{documentId}.{ext}
          → storageService.uploadFile() → Firebase Storage
          → documentRepository.createDocument() → Firestore documents/{documentId}
  → SnackBar "Upload successful"
  → userDocumentsProvider auto-updates via Firestore stream
```

### 6.2 Upload Details

| Aspect | Implementation |
|--------|----------------|
| File types | `pdf`, `jpg`, `jpeg`, `png` (client-side via FilePicker) |
| Storage path | `documents/{userId}/{documentId}.{ext}` |
| Firestore collection | `documents` |
| Document ID generation | Client timestamp (`millisecondsSinceEpoch`) |
| OCR trigger | Implicit — Storage upload triggers Cloud Function (backend, not Flutter) |
| Upload progress | **Not found** — binary loading state on FAB only |
| File size validation | **Not found in Flutter** (backend enforces 10 MB) |

### 6.3 Delete Flow

```
Dashboard ListTile delete icon
  → documentController.deleteDocument(documentId)
      → FirestoreDocumentService.deleteDocument()
          → storageService.deleteFile(storagePath)
          → documentRepository.deleteDocument() → sets isDeleted: true (soft delete)
```

**Note:** Storage file is hard-deleted; Firestore record is soft-deleted (`isDeleted: true`). OCR results and Storage OCR text are **not** cleaned up from Flutter.

---

## 7. OCR Result Loading Flow

### 7.1 Data Layer Flow (implemented, no UI)

```
ocrResultProvider(documentId)          [StreamProvider.family — UNUSED in screens]
  → OcrController.watchOcrResult(documentId)
      → FirestoreOcrRepository.watchOcrResult(documentId)
          → Firestore stream: ocr_results/{documentId}
          → if v2 (ocrTextPath present, no inline extractedText):
                → Firebase Storage: ref(ocrTextPath).getData()
                → utf8.decode → resolvedExtractedText
          → OcrResultMapper.fromMap(documentId, data, resolvedExtractedText)
              → OcrResult entity
```

### 7.2 v1 / v2 Compatibility

| Record type | Detection | Text resolution |
|-------------|-----------|-----------------|
| v1 (legacy) | `extractedText` inline in Firestore | Direct from Firestore |
| v2 (production) | `ocrTextPath` present, no `extractedText` | Loaded from Storage `ocr-results/{documentId}/full_text.txt` |

**Verified in:** `ocr_result_mapper.dart`, `firestore_ocr_repository.dart`

### 7.3 OCR Entity vs Backend Schema Gap

The repository loads Firestore data, but `OcrResult` entity and `OcrResultMapper` **do not map** these backend v2 fields:

| Backend field (v2) | In `OcrResult` entity? | In mapper? |
|--------------------|------------------------|------------|
| `summary` | ✅ | ✅ |
| `documentType` | ✅ | ✅ |
| `extractedText` / Storage text | ✅ | ✅ |
| `ocrTextPath` | ✅ | ✅ |
| `ocrCharacterCount` | ✅ | ✅ |
| `processingVersion` | ✅ | ✅ |
| `riskLevel` | ✅ (optional) | ✅ — **backend does not currently write this field** |
| `criticalFindings` | ❌ | ❌ |
| `normalFindings` | ❌ | ❌ |
| `recommendedFollowUp` | ❌ | ❌ |
| `ocrConfidence` | ❌ | ❌ |
| `pageCount` | ❌ | ❌ |
| `handwritingDetected` | ❌ | ❌ |
| `extractionWarning` | ❌ | ❌ |
| `ocrProvider` | ❌ | ❌ |

**Impact:** Even if a detail screen is built today, medical insights UI cannot render findings without model/mapper extensions.

### 7.4 OCR UI Consumption

| Item | Status |
|------|--------|
| `ocrResultProvider` defined | ✅ |
| Any screen watches `ocrResultProvider` | ❌ **Not found** |
| OCR processing indicator on dashboard | ❌ **Not found** |
| Detail screen for summary/findings | ❌ **Not found** |

---

## 8. Repositories Inventory

| Repository | Interface | Implementation | Firestore collection |
|------------|-----------|----------------|----------------------|
| Auth | `AuthRepository` | `FirebaseAuthRepository` | Firebase Auth (not Firestore) |
| User | `UserRepository` | `FirestoreUserRepository` | `users` |
| Document | `DocumentRepository` | `FirestoreDocumentRepository` | `documents` |
| OCR | `OcrRepository` | `FirestoreOcrRepository` | `ocr_results` + Storage |

### 8.1 Repository Methods

**AuthRepository**
- `getCurrentUser()`, `authStateChanges()`, `signOut()`

**UserRepository**
- `getUser()`, `createUser()`, `updateUser()`, `watchUser()` — `watchUser` **unused in providers/UI**

**DocumentRepository**
- `createDocument()`, `updateDocument()`, `deleteDocument()` (soft), `getDocument()`, `watchUserDocuments()`

**OcrRepository**
- `getOcrResult()`, `watchOcrResult()` — both **unused in UI**

---

## 9. Models / Entities Inventory

| Entity | File | Fields | Serialization |
|--------|------|--------|---------------|
| `AuthUser` | `auth/domain/entities/auth_user.dart` | id, email, displayName, photoUrl | Extension on Firebase `User` |
| `AppUser` | `user/domain/entities/app_user.dart` | uid, email, displayName, photoUrl, createdAt, lastLoginAt, isActive | `AppUserMapper` |
| `AppDocument` | `document/domain/entities/app_document.dart` | id, ownerId, fileName, documentType, storagePath, downloadUrl, createdAt, updatedAt, isDeleted | `AppDocumentMapper` |
| `OcrResult` | `ocr/domain/entities/ocr_result.dart` | documentId, extractedText, summary, createdAt + optional v2 fields | `OcrResultMapper` |
| `DocumentType` | `document/domain/enums/document_type.dart` | 7 enum values | Stored as enum `.name` string |

### 9.1 Missing Models (for Stitch / medical insights UI)

| Model | Status |
|-------|--------|
| `CriticalFinding` | **Not found in repository** |
| `MedicalInsights` / `AnalysisResult` | **Not found in repository** |
| `OcrProcessingStatus` enum | **Not found in repository** |
| Search result / filter models | **Not found in repository** |

### 9.2 Freezed / Code Generation

| Tool | In pubspec | Generated files | Used |
|------|------------|-----------------|------|
| `freezed` | ✅ | **0 `.freezed.dart` files** | ❌ |
| `json_serializable` | ✅ | **0 `.g.dart` files** | ❌ |

All entities are plain Dart classes with manual mappers.

---

## 10. Dead Code & Unused Providers

### 10.1 Confirmed Dead Code (defined, never imported)

| Symbol | File | Notes |
|--------|------|-------|
| `LoggerService` | `core/services/logger_service.dart` | No imports anywhere in `lib/` |
| `dioProvider` | `app/providers/network_providers.dart` | No consumer in `lib/` |
| `DocumentState` hierarchy | `document/application/document_state.dart` | `DocumentInitial/Loading/Loaded/Error` — unused; dashboard uses `AsyncValue` instead |
| `AuthState` hierarchy | `auth/application/auth_state.dart` | `AuthInitial/Authenticated/Unauthenticated` — unused |
| `UserState` hierarchy | `user/application/user_state.dart` | `UserInitial/Loaded/Error` — unused |
| `OcrState` hierarchy | `ocr/application/ocr_state.dart` | `OcrInitial/Loading/Loaded/Error` — unused |

### 10.2 Providers Defined but Not Consumed by UI

| Provider | Wired in graph? | UI consumer |
|----------|-----------------|-------------|
| `ocrResultProvider` | ✅ | ❌ None |
| `ocrControllerProvider` | ✅ (via ocrResultProvider) | ❌ None |
| `userRepositoryProvider.watchUser()` | N/A — no `watchUserProvider` exists | ❌ |

### 10.3 Controller Methods Without UI

| Method | Controller | UI caller |
|--------|------------|-----------|
| `signOut()` | `AuthController` | **None** |
| `getOcrResult()` | `OcrController` | **None** (only `watchOcrResult` exposed via provider) |
| `DocumentRepository.updateDocument()` | — | **Never called** |
| `DocumentRepository.getDocument()` | — | Only used internally by delete flow |

### 10.4 Empty Directories

| Path | Status |
|------|--------|
| `lib/core/network/` | Empty |
| `lib/core/utils/` | Empty |
| `lib/core/extensions/` | Empty |

### 10.5 Unused pubspec Dependencies (in `lib/`)

These are declared in `pubspec.yaml` but have **no imports in `lib/`**:

- `firebase_messaging`
- `firebase_crashlytics`
- `firebase_app_check`
- `image_picker` (dashboard uses `file_picker` instead)
- `cached_network_image`
- `lottie`
- `connectivity_plus`
- `freezed_annotation`
- `json_annotation`

---

## 11. Missing Pieces for Stitch Implementation

Stitch UI designs will require wiring into the existing architecture. Based on repository inspection, the following are **required before or alongside** Stitch screen implementation:

### 11.1 Must Add — Routing & Screens

| Item | Priority | Rationale |
|------|----------|-----------|
| **Document detail route** e.g. `/documents/:id` | P0 | No detail screen or path param route exists |
| **Document detail screen** | P0 | OCR data has no presentation target |
| **Auth redirect guard** on GoRouter | P0 | `/dashboard` unprotected |
| **Shell / bottom nav** (if Stitch design includes tabs) | P1 | No `ShellRoute`; only flat 3-route stack |
| **Library screen** (if distinct from dashboard) | P1 | Not found — clarify if Stitch "Library" = current dashboard |
| **Search screen + route** | P2 | Entire feature missing |
| **Settings / profile screen** | P2 | Not found; sign-out needs a home |

### 11.2 Must Add — Models & Mappers

| Item | Priority | Rationale |
|------|----------|-----------|
| `CriticalFinding` entity | P0 | Backend writes `criticalFindings[]`; Flutter ignores them |
| Extend `OcrResult` with `normalFindings`, `recommendedFollowUp`, `extractionWarning`, `ocrConfidence`, `handwritingDetected` | P0 | Required for medical insights UI |
| `OcrProcessingStatus` derived state (none / processing / ready / error) | P0 | Dashboard needs OCR badge; derive from `ocrResultProvider` null vs data |

### 11.3 Must Add — Providers

| Item | Priority | Rationale |
|------|----------|-----------|
| Wire `ocrResultProvider(documentId)` into detail screen | P0 | Provider exists but unused |
| `documentDetailProvider` combining `AppDocument` + `OcrResult` | P1 | Single screen needs both streams |
| `currentUserProvider` / `watchUserProvider` | P2 | Profile header in Stitch designs |
| Search providers | P2 | No search infrastructure |

### 11.4 Must Add — Shared UI Layer

| Item | Priority | Rationale |
|------|----------|-----------|
| `lib/shared/widgets/` or `core/widgets/` | P1 | No reusable components; Stitch designs need shared cards, badges, loading states |
| App bar with user avatar / sign-out | P1 | Not present on dashboard |
| OCR status chip (processing / ready / warning) | P1 | For library/dashboard list items |
| Medical finding card widget | P1 | For detail screen |
| Disclaimer footer widget | P2 | Backend appends disclaimer to summary |

### 11.5 Should Clean Up Before UI Work

| Item | Priority | Rationale |
|------|----------|-----------|
| Remove or adopt `*State` sealed classes (`DocumentState`, `OcrState`, etc.) | P2 | Dead code; Riverpod `AsyncValue` is the de facto pattern |
| Remove `LoggerService`, `dioProvider` or wire them | P3 | Dead code noise |
| Decide on Freezed adoption vs remove from pubspec | P3 | Architectural consistency |

### 11.6 Optional — Aligns with Stitch Polish

| Item | Notes |
|------|-------|
| Document viewer (PDF/image) | `downloadUrl` available on `AppDocument`; no viewer widget |
| Pull-to-refresh on document list | Not found |
| Upload progress | Not found |
| Empty state illustrations | Dashboard shows plain `Text('No documents uploaded')` |
| Dark mode | `AppTheme.darkTheme` defined in `main.dart`; screens use default Material |

---

## 12. Summary Tables

### 12.1 What Exists Today

| Category | Count | Ready for Stitch? |
|----------|-------|-------------------|
| Screens | 3 | Partial — list + auth only |
| Routes | 3 | ❌ Need detail + guards |
| Providers | 19 (17 in graph) | Partial — OCR provider unused |
| Repositories | 4 | ✅ Data layer ready |
| Entities | 5 | ⚠️ OCR entity incomplete vs backend |
| Mappers | 4 | ⚠️ OCR mapper missing findings |
| Presentation features | 2 (`splash`, `auth`) + 1 (`dashboard`) | ❌ OCR/document have no UI |

### 12.2 Screen Checklist (User Request)

| Screen | Exists | Route | Provider wired |
|--------|--------|-------|----------------|
| Dashboard | ✅ | `/dashboard` | `userDocumentsProvider` |
| Library | ❌ (dashboard acts as list) | — | — |
| Detail | ❌ | — | `ocrResultProvider` ready but unwired |
| Search | ❌ | — | — |

### 12.3 Recommended Implementation Order for Stitch

```
1. Extend OcrResult entity + mapper (findings, warnings, confidence)
2. Add /documents/:id route + DocumentDetailScreen
3. Wire ocrResultProvider + document lookup into detail screen
4. Add GoRouter auth redirect
5. Enhance DashboardScreen list items (OCR status chip, tap → detail)
6. Add shared widgets layer from Stitch components
7. Add search feature (if in Stitch designs)
8. Add library tab or rename dashboard (if Stitch distinguishes them)
```

---

## 13. Appendix — File Count by Feature

| Feature | Dart files | Has presentation? |
|---------|------------|-------------------|
| `auth` | 12 | ✅ `login_screen.dart` |
| `user` | 7 | ❌ |
| `document` | 12 | ❌ (logic in dashboard) |
| `ocr` | 8 | ❌ |
| `splash` | 1 | ✅ `splash_screen.dart` |
| `dashboard` | 1 | ✅ `dashboard_screen.dart` |
| `app` + `core` | 7 | N/A |

**Total `lib/` Dart files: 52** (including `main.dart`, `firebase_options.dart`)

---

*End of Flutter architecture audit. No code was modified.*
