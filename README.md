# azulon_studio_test_task

A production-grade Flutter app with Clean Architecture: products list with pagination, search, filters, and responsive master-detail layout.

---

## 1. Setup & Run Instructions

### Prerequisites

- **Flutter**: Compatible with Flutter 3.x (SDK `^3.10.3` per `pubspec.yaml`). Use a stable channel release that satisfies the SDK constraint.
- **Dart**: 3.10.3 or later.

### Install dependencies

```bash
flutter pub get
```

### Build and run

```bash
# Run on a connected device or emulator
flutter run

# Build APK (Android)
flutter build apk

# Build iOS (requires macOS and Xcode)
flutter build ios
```

### Run tests

```bash
flutter test
```

---

## 2. Architecture Overview

### Folder structure

The project uses **feature-first** organization with a shared **core** layer:

```
lib/
├── main.dart
├── core/
│   ├── di/                 # GetIt dependency injection
│   ├── theme/              # App theme, light/dark, ThemeCubit, extensions
│   ├── design_system/       # Reusable UI components and layout tokens
│   │   ├── components/     # AppCard, AppButton, EmptyState, ErrorState, etc.
│   │   └── layout/         # AppSpacing, AppContainer
│   ├── network/            # Dio client, API service
│   └── error/              # Failures, exceptions
└── features/
    └── products/
        ├── data/           # Data sources, models, repository impl
        ├── domain/         # Entities, repository contracts, use cases
        └── presentation/   # Bloc, pages, widgets
```

- **Core** holds DI, theming, design system, network, and error types used across features.
- **Features** are self-contained: each has `data`, `domain`, and `presentation` following Clean Architecture.

### State management approach

- **flutter_bloc** for app and feature state.
- **ProductsBloc** handles both list and detail:
  - List: `ProductsInitial` → `ProductsLoading` → `ProductsLoaded` / `ProductsLoadingMore` / `ProductsError`.
  - Detail: `ProductDetailLoading` → `ProductDetailsLoaded` / `ProductDetailError` / `ProductDetailEmpty`.
- **ThemeCubit** (Cubit) for theme mode (system / light / dark), provided at app level.
- List state is cached in the list UI when in master-detail so the left panel stays visible while the right shows detail.

### Key architectural decisions

- **Single ProductsBloc** for list and detail to reuse data and support master-detail without extra sync.
- **GoRouter** for declarative routes: `/` (responsive list), `/products/:id` (detail; supports deep link and optional `extra` bloc).
- **Responsive layout in UI only**: breakpoint at 768px; master-detail vs push navigation is decided in `ResponsiveProductsScreen`, not in the router.
- **Dartz** `Either<Failure, T>` for use case results; repository/use case layer stays free of UI concerns.
- **GetIt** for DI; Bloc created per route where needed (e.g. `ProductsBloc` for `/`, optional reuse for `/products/:id` via `extra`).

---

## 3. Design System Rationale

### Component API choices

- **AppCard**: Optional `onTap`, `padding`, `margin`, `elevation`, `borderRadius`. When `onTap` is set, the card is wrapped in `InkWell` for consistent tap feedback. Defaults use `AppSpacing.md` and a 12px radius so screens can rely on consistent spacing without passing values everywhere.
- **AppButton**: Variants `primary`, `secondary`, `outlined`, `text`; optional `icon`, `isLoading`. Matches Material 3 `FilledButton` / `OutlinedButton` / `TextButton` while keeping a single API.
- **EmptyState / ErrorState**: Message plus optional actions (e.g. `onClearFilters`, `onRetry`) so list and detail screens can reuse the same empty/error UX.
- **AppSpacing**: Static constants (`xs`–`xxl`) and prebuilt `SizedBox` widgets (`verticalLg`, `horizontalMd`, etc.) to avoid magic numbers and keep layout consistent.

### How theming works

- **ThemeData** is built from `appTheme(Brightness)` using `LightTheme` and `DarkTheme` (from `light_theme.dart` / `dark_theme.dart`).
- **ThemeCubit** holds `ThemeMode` (system / light / dark). `MyApp` uses `BlocBuilder<ThemeCubit, ThemeMode>` and passes `theme`, `darkTheme`, and `themeMode` to `MaterialApp.router`.
- **Semantic colors** (e.g. success, star, surfaceVariant) live in `AppColors` (light/dark implementations). UI reads them via `ThemeExtensions` on `BuildContext`: `context.appColors`, `context.textTheme`, `context.colorScheme`, so widgets stay independent of concrete theme files.

### Deviations from design spec

- No formal design spec was provided; the design system was inferred from existing screens. Components follow Material 3–style defaults and the existing color set. Any future spec can be applied by updating `AppColors`, `LightTheme`/`DarkTheme`, and spacing in `AppSpacing` without changing component APIs.

---

## 4. Limitations

- **Master-detail + pagination**: When a product is selected on wide layout, the list is drawn from cached state. Loading more (pagination) does not run until the bloc is back in a list state (e.g. after navigating away from detail). Improving this would require the bloc to support “load more” while in a detail state (e.g. using stored list snapshot).
- **Deep linking**: The route `/products/:id` is defined and works when navigated to (e.g. `context.go`, or initial route). Tying the app’s initial route to the platform deep link (e.g. `getInitialLink`) is not implemented; that would be an app-level change (e.g. set `initialLocation` from the link).
- **Full-app widget test**: A full app smoke test that pumps `MyApp()` and waits for network would require mocked HTTP (e.g. custom `HttpClient` or mocked Dio) and injection overrides. The current smoke test only pumps a small subtree (e.g. `EmptyState`) to avoid test-environment network and DI.
- **ErrorState layout**: In very small viewports (e.g. some test bounds), `ErrorState` can overflow. A follow-up would be to wrap content in a scrollable or flexible layout for small heights.
- **Image validation**: Invalid or empty image URLs are handled with placeholders and `developer.log` warnings. There is no strict validation (e.g. blocking non-http(s) URLs) in the model; the UI treats load failure as “show placeholder.”

---

## 5. AI Tools Usage

- **Responsive layout**: AI suggested the master-detail split, breakpoint at 768px, `ResponsiveProductsScreen`, and an optional `onProductSelected` on `ProductsPage`. This was implemented and then fixed so the left panel stays visible when a product is selected (list state caching in the page).
- **Data validation and performance**: AI proposed validation and logging in `ProductModel` (price sentinel, brand/category defaults, image URL warnings), “Price unavailable” in the UI for invalid price, and use of `cached_network_image`. These were implemented with minor refinements (lint fixes, consistent use of `developer.log`).
- **Tests**: AI added unit tests for `ProductsBloc` (with `bloc_test` and `mocktail`) and for `ProductModel.fromJson`, plus widget tests for `AppCard` and `EmptyState`. The default counter-style `widget_test` was replaced by a small smoke test that does not depend on full app or network.
- **README**: This README was generated from the codebase structure, `pubspec.yaml`, and the patterns above. Sections were filled to match the actual setup, architecture, design system, limitations, and where AI was used; no existing content was removed, only expanded and structured.

---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
