# Phase 1: Project Foundation & Design System

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Set up project dependencies, folder structure, design system (theme/colors/typography), app shell, empty router, and wire everything into `main.dart`.

**Architecture:** Clean Architecture feature-first layering. Each feature gets its own directory tree. Core infrastructure lives at `src/core/`.

**Tech Stack:** Flutter 3.41, Dart 3.11, Riverpod 3.3, GoRouter 17.2, Supabase Flutter 2.12

---
## Task 1: Update dependencies

**Files:**
- Modify: `pubspec.yaml` (full rewrite)
- Create: `.env`

- [ ] **Step 1: Rewrite pubspec.yaml**

```yaml
name: intra_buddy_mobile_v2
description: "Student-facing mobile app for UniKL internship management"
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.11.5

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.12.4
  supabase: ^2.10.4
  flutter_riverpod: ^3.3.1
  hooks_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2
  go_router: ^17.2.3
  dio: ^5.5.0
  dartz: ^0.10.1
  json_annotation: ^4.9.0
  intl: ^0.20.2
  image_picker: ^1.1.0
  file_picker: ^11.0.2
  url_launcher: ^6.3.1
  flutter_dotenv: ^6.0.1
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  riverpod_generator: ^4.0.0
  riverpod_lint: ^3.1.3
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
  assets:
    - .env
```

- [ ] **Step 2: Create `.env` file**

```
SUPABASE_URL=https://yyqoleelprtldlvvizdk.supabase.co
SUPABASE_ANON_KEY=placeholder
```

- [ ] **Step 3: Run `flutter pub get`**

Run: `flutter pub get`
Expected: All packages resolved successfully.

- [ ] **Step 4: Update `analysis_options.yaml`**

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - riverpod_lint

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
```

- [ ] **Step 5: Commit**

```bash
git init && git add -A && git commit -m "chore: add project dependencies and configuration"
```

---

## Task 2: Create folder structure and failures

**Files:**
- Create: `lib/src/core/errors/failures.dart`
- Create: `lib/src/core/constants/app_constants.dart`
- Create: directory structure for all features

- [ ] **Step 1: Create `lib/src/core/errors/failures.dart`**

```dart
import 'package:dartz/dartz.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, String> errors;
  const ValidationFailure(this.errors) : super('Validation failed');
}

typedef Result<T> = Either<Failure, T>;
```

- [ ] **Step 2: Create `lib/src/core/constants/app_constants.dart`**

```dart
class AppConstants {
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';
  static const int uploadMaxBytes = 5 * 1024 * 1024; // 5 MB
  static const String studentEmailDomain = '@s.unikl.edu.my';
  static const int studentIdLength = 11;
  static const int minPasswordLength = 6;
}
```

- [ ] **Step 3: Create directory structure**

```bash
mkdir -p lib/src/app/theme
mkdir -p lib/src/core/constants
mkdir -p lib/src/core/errors
mkdir -p lib/src/core/network
mkdir -p lib/src/core/services
mkdir -p lib/src/core/utils
mkdir -p lib/src/features/auth/domain/entities
mkdir -p lib/src/features/auth/domain/repositories
mkdir -p lib/src/features/auth/domain/usecases
mkdir -p lib/src/features/auth/data/datasources
mkdir -p lib/src/features/auth/data/models
mkdir -p lib/src/features/auth/data/repositories
mkdir -p lib/src/features/auth/presentation/providers
mkdir -p lib/src/features/auth/presentation/screens
mkdir -p lib/src/features/auth/presentation/widgets
mkdir -p lib/src/features/dashboard/domain/entities
mkdir -p lib/src/features/dashboard/domain/repositories
mkdir -p lib/src/features/dashboard/domain/usecases
mkdir -p lib/src/features/dashboard/data/datasources
mkdir -p lib/src/features/dashboard/data/models
mkdir -p lib/src/features/dashboard/data/repositories
mkdir -p lib/src/features/dashboard/presentation/providers
mkdir -p lib/src/features/dashboard/presentation/screens
mkdir -p lib/src/features/dashboard/presentation/widgets
mkdir -p lib/src/features/checklist/domain/entities
mkdir -p lib/src/features/checklist/presentation/screens
mkdir -p lib/src/features/jobs/presentation/screens
mkdir -p lib/src/features/chatbot/presentation/screens
mkdir -p lib/src/features/my_documents/presentation/screens
mkdir -p lib/src/features/notifications/presentation/screens
mkdir -p lib/src/features/logbook/presentation/screens
mkdir -p lib/src/features/profile/presentation/screens
mkdir -p lib/src/features/settings/presentation/screens
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "chore: create project folder structure and core types"
```

---

## Task 3: Build the design system

**Files:**
- Create: `lib/src/app/theme/app_colors.dart`
- Create: `lib/src/app/theme/app_typography.dart`
- Create: `lib/src/app/theme/app_theme.dart`

- [ ] **Step 1: Create `app_colors.dart`**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF1D4ED8);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFDBEAFE);
  static const onPrimaryContainer = Color(0xFF1E3A5F);

  // Secondary
  static const secondary = Color(0xFF0D9488);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFCCFBF1);
  static const onSecondaryContainer = Color(0xFF134E4A);

  // Tertiary (Amber)
  static const tertiary = Color(0xFFF59E0B);
  static const onTertiary = Color(0xFF1E293B);
  static const tertiaryContainer = Color(0xFFFEF3C7);
  static const onTertiaryContainer = Color(0xFF78350F);

  // Error
  static const error = Color(0xFFEF4444);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onErrorContainer = Color(0xFF7F1D1D);

  // Neutral
  static const background = Color(0xFFF8FAFC);
  static const onBackground = Color(0xFF1E293B);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1E293B);
  static const outline = Color(0xFFE2E8F0);
  static const muted = Color(0xFF64748B);
}
```

- [ ] **Step 2: Create `app_typography.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    final inter = GoogleFonts.interTextTheme();
    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: inter.headlineLarge?.copyWith(
        fontSize: 28,
        height: 1.29,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
```

- [ ] **Step 3: Create `app_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      outline: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primaryContainer,
        backgroundColor: AppColors.surface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.muted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: add design system with Material 3 theme"
```

---

## Task 4: Wire up app entry point and router

**Files:**
- Create: `lib/src/app/intra_buddy_app.dart`
- Create: `lib/src/app/router.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create `router.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Login Screen')),
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Sign Up Screen')),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist),
                label: 'Checklist',
              ),
              NavigationDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: 'Jobs',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                selectedIcon: Icon(Icons.chat),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: 'Documents',
              ),
            ],
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Dashboard')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/checklist',
              name: 'checklist',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Checklist')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              name: 'jobs',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Jobs')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Chat')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-documents',
              name: 'my-documents',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('My Documents')),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

- [ ] **Step 2: Create `intra_buddy_app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'router.dart';

class IntraBuddyApp extends StatelessWidget {
  const IntraBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'INTRA Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 3: Update `main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/constants/app_constants.dart';
import 'src/app/intra_buddy_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey];
  final supabaseAnonKey = dotenv.env[AppConstants.supabaseAnonKeyKey];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw StateError('Missing SUPABASE_URL in .env');
  }
  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const IntraBuddyApp());
}
```

- [ ] **Step 4: Verify app builds**

Run: `flutter analyze`
Expected: No errors (some unused import warnings might appear — suppress them in analysis_options.yaml as needed).

- [ ] **Step 5: Remove unused import from `intra_buddy_app.dart`**

Actually, `dart:io` was not imported. The `intra_buddy_app.dart` above doesn't import `flutter_dotenv` — fix it.

Wait, the import of `flutter_dotenv` is in main.dart, not intra_buddy_app.dart. That's correct. Remove the unused import from `intra_buddy_app.dart`:

Remove `import 'package:flutter_dotenv/flutter_dotenv.dart';` from `intra_buddy_app.dart` — we don't need it there.

- [ ] **Step 6: Commit**

```bash
git add -A && git commit -m "feat: add app entry point, router with bottom nav, and supabase init"
```

---

## Task 5: Write placeholders for empty feature screens

**Files:**
- Create placeholder screens for all remaining features under `/my-documents`, `/profile`, `/settings`, `/logbook`, `/notifications`

Since the router currently uses inline Scaffolds, we'll replace them with proper files. This will be done in Phase 3 (App Shell) — for now, the inline scaffolds are fine.

- [ ] **Step 1: Accept inline scaffolds** — no changes needed. The Phase 1 deliverable is a working themed app with navigation.

- [ ] **Step 2: Final verification**

Run: `flutter analyze` — clean
Run: `dart format .` — formatted

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "chore: finalize phase 1 scaffold"
```

---

## Phase 1 Deliverable

- Themed Material 3 app with Inter font, custom color tokens
- GoRouter with 5-tab `StatefulShellRoute.indexedStack` bottom nav
- Supabase initialized from `.env` at startup
- Core types (`Failure`, `Result`, `AppConstants`) and folder structure in place
- Empty feature directories ready for Phases 2+
- `flutter analyze` passes cleanly
- `flutter run` shows a themed app with navigation shell
