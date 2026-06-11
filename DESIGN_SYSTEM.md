# Aarogya Vault — Design System

Design tokens and reusable components for the Flutter MVP, reverse-engineered from **Stitch design exports** attached to the project.

## Source methodology

| Item | Detail |
|------|--------|
| Source files | 19 Stitch PNG exports in `.cursor/projects/.../assets/` |
| Extraction | Programmatic pixel sampling (dominant-color analysis per screen region) |
| SVG exports | Not present in workspace; tokens derived from raster exports only |
| Font | **Inter** (confirmed on website + Stitch typography) |

Screens sampled: Splash (light/dark), Dashboard (light/dark/loading/empty), Record Library (populated/empty/loading), Record Details, Upload Record (light/dark), Upload Failed (light/dark), Login (dark).

---

## Color palette

### Brand (shared)

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#0F766E` | Light-mode primary (buttons, nav active, overview card) |
| `primaryDark` | `#005C55` | Active chips, darker accents |
| `primaryLight` | `#127870` | Quick Upload, secondary teal surfaces |
| `primaryBright` | `#14B8A6` | Dark-mode primary |
| `primaryBrightAlt` | `#4FD1C5` | Dark-mode CTA buttons (Login, Upload Failed) |
| `success` | `#00AA55` | Security shield, verified states |
| `error` | `#BA1A1A` | Upload failed icon, alerts |
| `warning` | `#E7D394` | Pending badge |

### Light theme

| Token | Hex | Usage |
|-------|-----|-------|
| `lightBackground` | `#F7FAF8` | Scaffold background |
| `lightSurface` | `#FFFFFF` | Cards, inputs |
| `lightSurfaceMuted` | `#F5F8F6` | Subtle fills |
| `lightBorder` | `#E5EEEE` | Dividers, card edges |
| `lightBorderStrong` | `#BDC9C6` | Upload zone border, outline buttons |
| `lightTextPrimary` | `#181C1C` | Headings, body |
| `lightTextSecondary` | `#6C7573` | Subtitles, labels |
| `lightTextMuted` | `#9AA19F` | Placeholders, hints |
| `lightIconTintTeal` | `#EFF5F3` | Document / doctor icon backgrounds |
| `lightIconTintPeach` | `#F2EBE9` | Hospital / prescription icon backgrounds |
| `lightBadgeVerifiedBg` | `#E0F2F1` | Verified pill background |
| `lightChipInactiveBg` | `#E5E9E7` | Filter chip (inactive) |

### Dark theme

| Token | Hex | Usage |
|-------|-----|-------|
| `darkBackground` | `#131313` | Scaffold background |
| `darkSurface` | `#201F1F` | Cards, list items |
| `darkSurfaceElevated` | `#2A2A2A` | Login card, input containers |
| `darkSurfaceInput` | `#2F3231` | Text fields |
| `darkBorder` | `#343332` | Outlines |
| `darkTextPrimary` | `#FFFFFF` | Headings |
| `darkTextSecondary` | `#BBCAC6` | Subtitles |
| `darkTextMuted` | `#919C99` | Hints |
| `darkOnPrimary` | `#131313` | Text on bright teal buttons |

### Splash gradient (light)

| Stop | Hex |
|------|-----|
| Top | `#E0F7F5` |
| Mid | `#E1F0F0` |
| Bottom | `#FFFFFF` |
| Logo glow | `#CEF8F4` |

---

## Typography

**Family:** Inter (bundled variable font at `assets/fonts/Inter.ttf`)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 32 | 700 | User greeting ("Aditi") |
| `headlineLarge` | 24 | 700 | Empty-state titles, section headers |
| `headlineMedium` | 20 | 700 | App bar title |
| `titleLarge` | 18 | 600 | Record card titles |
| `titleMedium` | 16 | 600 | Card labels |
| `bodyLarge` | 16 | 400 | Body copy, summaries |
| `bodyMedium` | 14 | 400 | Subtitles, metadata |
| `bodySmall` | 12 | 400 | Captions, file info |
| `labelLarge` | 16 | 600 | Button text |
| `labelMedium` | 12 | 600 | Section labels (uppercase) |
| `labelSmall` | 10 | 500 | Bottom nav labels |

---

## Spacing scale

Base unit: **4px**

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 4 | Tight gaps |
| `xs` | 8 | Icon-to-text, chip padding |
| `sm` | 12 | Card vertical gap |
| `md` | 16 | Screen padding, card padding |
| `lg` | 20 | Section spacing |
| `xl` | 24 | Large section gaps |
| `xxl` | 32 | Hero spacing |
| `xxxl` | 48 | Empty-state vertical rhythm |

### Component dimensions

| Component | Value |
|-----------|-------|
| Screen horizontal padding | 16px |
| Primary button height | 52px |
| Bottom nav height | 64px |
| Icon size (standard) | 24px |
| Icon container (cards) | 40×40px |

---

## Border radius

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4 | Avatar corners |
| `sm` | 8 | Icon containers |
| `md` | 12 | Search bar, inputs, small cards |
| `lg` | 16 | Standard cards |
| `xl` | 24 | Logo container |
| `pill` | 100 | Buttons, chips, progress bar |

---

## Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `cardShadow` (light) | `0 4px 16px rgba(15,23,42,0.05)` | Elevated cards |
| `cardShadowDark` | `0 4px 12px rgba(0,0,0,0.20)` | Dark cards |

---

## Component inventory

### Theme (`lib/core/theme/`)

| File | Purpose |
|------|---------|
| `app_colors.dart` | All color tokens |
| `app_typography.dart` | Inter text styles |
| `app_spacing.dart` | Spacing + component dimensions |
| `app_radius.dart` | Border radii |
| `app_theme.dart` | `ThemeData` light + dark assembly |

`lib/app/theme/app_theme.dart` re-exports the core theme for existing imports.

### Widgets (`lib/shared/widgets/`)

| Widget | Variants | Stitch reference |
|--------|----------|------------------|
| `AppButton` | primary, secondary, outline, text | Quick Upload, Retry Upload, Add New Record |
| `AppCard` | elevated, filled, outlined | Overview, summary, upload zone |
| `AppDashedCard` | dashed border | Record Library empty state |
| `AppTextField` | search / form | Library search, Login inputs |
| `AppLoadingIndicator` | circular, linear, skeleton | Splash progress, dashboard/library loading |
| `AppSkeletonCard` | card skeleton | Loading screens |
| `AppEmptyState` | icon + title + action | Library empty, Upload Failed |

---

## Navigation patterns (for future screens)

| Pattern | Spec |
|---------|------|
| Bottom nav items | Home, Records, Upload, Settings |
| Active state (light) | Primary teal icon + label |
| Active state (dark) | Teal icon in pill background |
| Inactive | Muted gray icon + label |
| App bar | Centered title in primary teal, profile left, search right |

---

## Usage

```dart
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  // ...
);

AppButton(
  label: 'Quick Upload',
  leading: Icon(Icons.add),
  onPressed: () {},
);
```

## Tests

```bash
cd apps/mobile_app
flutter analyze
flutter test
```

Test files:
- `test/core/theme/design_tokens_test.dart`
- `test/shared/widgets/shared_widgets_test.dart`
- `test/features/ocr/` (existing)

## Out of scope (this pass)

- Screen implementations
- Bottom navigation shell
- Custom icon font / SVG icon set
- Light/dark theme toggle UI
