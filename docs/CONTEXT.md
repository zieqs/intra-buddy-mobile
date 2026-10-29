# INTRA Buddy Mobile — System Summary

---

## 1. Project Identity & Purpose

| Field | Value |
|-------|-------|
| **Name** | `intra_buddy_mobile_v2` |
| **Repository** | `github.com/zieqs/intra-buddy` |
| **Version** | `0.1.0+1` |
| **Description** | Student-facing mobile app for UniKL internship management |
| **Platform** | Flutter (iOS, Android) |
| **Primary audience** | UniKL students enrolled in industrial training (INTRA) |

**Purpose:** Help students track internship tasks — milestone checklists, job applications, weekly logbook submissions (status only, not a place to submit the logbooks), document management, notifications, and a FAQ-based chatbot assistant.

---

## 2. Scope & Boundaries

This is a **two-person team project** with a shared Supabase backend:

| Component | Repo | Responsibility | Built by |
|-----------|------|----------------|----------|
| Mobile App | `zieqs/intra-buddy` | Student-facing features | You |
| Web Dashboard | (separate repo) | Admin/coordinator tools | Teammate |

**In scope (mobile app):**
- Student auth (email/password via Supabase Auth)
- Dashboard with progress overview
- INTRA milestone checklist
- Job application tracker
- FAQ-based chatbot assistant
- My Documents (file uploads via Supabase Storage)
- Notifications inbox
- Weekly logbook status
- Profile view/edit
- Settings + sign out

**Out of scope (web dashboard):**
- FAQ management (CRUD)
- Semester management
- Broadcast messages
- User enrollment & role management
- Checklist template administration
- Student progress oversight

---

## 3. Team & Responsibilities

| Role | Responsibility |
|------|---------------|
| **You** | Student-facing Flutter mobile app (this repo) |
| **Teammate** | Admin/coordinator web dashboard (separate repo) |
| **Shared** | Supabase project `yyqoleelprtldlvvizdk.supabase.co` |

Both apps share the same Supabase backend (Postgres, Auth, Realtime, Storage).

---

## 4. Tech Stack

### Dependencies (from `pubspec.yaml`)

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK ^3.11.5 | Framework |
| `supabase_flutter` | ^2.12.4 | Supabase client for Flutter |
| `supabase` | ^2.10.4 | Core Supabase Dart package |
| `flutter_riverpod` | ^3.3.1 | State management |
| `riverpod_annotation` | ^4.0.2 | Riverpod code generation (not currently used) |
| `hooks_riverpod` | ^3.3.1 | Hooks + Riverpod integration |
| `go_router` | ^17.2.3 | Declarative routing |
| `dio` | ^5.5.0 | HTTP client (imported but unused) |
| `dartz` | ^0.10.1 | Functional programming (Either monad for Result type) |
| `json_annotation` | ^4.11.0 | JSON serialization |
| `intl` | ^0.20.2 | Date formatting (not currently used) |
| `image_picker` | ^1.1.0 | Camera/gallery for document upload |
| `file_picker` | ^11.0.2 | File picker for document upload |
| `url_launcher` | ^6.3.1 | Open external links (mailto) |
| `flutter_dotenv` | ^6.0.1 | Environment variables from `.env` |
| `google_fonts` | ^6.2.1 | Google Fonts (Inter) |
| `pdfx` | ^2.11.0 | In-app PDF rendering (native OS engine) |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `riverpod_generator` | ^4.0.0 | Riverpod code generation |
| `build_runner` | ^2.4.0 | Code generation runner |
| `riverpod_lint` | ^3.1.3 | Riverpod-specific linting |
| `json_serializable` | ^6.9.4 | JSON code generation |
| `mocktail` | ^1.0.4 | Mocking for tests |

### Architecture Decisions

- **State management:** Riverpod 3 with manual providers (`Provider`, `AsyncNotifierProvider`, `FutureProvider`, `NotifierProvider`)
- **Architecture:** Feature-first Clean Architecture with `domain/data/presentation` layers per feature
- **Routing:** GoRouter with `StatefulShellRoute.indexedStack` for 4-tab bottom nav persistence
- **Backend:** Supabase PostgreSQL + Auth + Storage
- **Auth:** Email/password only (no OAuth)
- **Chatbot:** Rule-based FAQ matching (no external LLM API)
- **Theme:** Material 3 light theme, Royal Blue/Teal/Amber palette, Inter font

---

## 5. Architecture Overview

### Layered Architecture (per feature)

```
feature_name/
  domain/
    entities/         Plain Dart classes (no Flutter, no database)
    repositories/     Abstract interfaces defining operations
    usecases/         Single-purpose business actions (optional)

  data/
    datasources/      Actual Supabase queries and API calls
    models/           JSON-serializable classes with fromJson/toJson
    repositories/     Implements domain interfaces, maps model ↔ entity

  presentation/
    providers/        Riverpod controllers (AsyncNotifier) with state
    screens/          UI widgets (ConsumerWidget / ConsumerStatefulWidget)
```

**Dependency rule:** Domain depends on nothing. Data depends on domain. Presentation depends on domain.

### Data Flow

```
Screen (ConsumerWidget)
  └─ watches Provider (AsyncNotifier / FutureProvider)
       └─ calls Repository (abstract interface from domain)
            └─ RepositoryImpl (implementation from data)
                 └─ RemoteDataSource (actual Supabase queries)
```

### Navigation Flow

```
Auth check (GoRouter redirect)
  ├─ Not logged in → /login or /signup
  └─ Logged in → / (StatefulShellRoute — 4 tabs + More)
       ├─ /dashboard     (tab 0 — DashboardHome)
       ├─ /checklist     (tab 1 — ChecklistScreen)
       ├─ /jobs          (tab 2 — JobsScreen)
       └─ /chat          (tab 3 — ChatbotScreen)
  ── /my-documents  (pushed from More menu)
  ── /logbook       (pushed from More menu)
  ── /notifications (pushed from More menu or AppBar bell)
  ── /profile       (pushed from More menu)
  ── /settings      (pushed from More menu)
```

Bottom nav has **5 items** (tabs 0–3 + More `Icons.more_horiz`). The More menu opens a modal bottom sheet containing: Weekly Logbook, Notifications, Documents, Profile, Settings, Logout.

---

## 6. Complete Project Structure

```
lib/
  main.dart                          # Entry point: Supabase init, ProviderScope,
                                     # MaterialApp.router with theme + router
  src/
    app/
      intra_buddy_app.dart           # ConsumerWidget wrapping MaterialApp.router
      router.dart                    # appRouterProvider with auth redirect +
                                     #   StatefulShellRoute + pushed routes
      theme/
        app_colors.dart              # Color palette constants
        app_typography.dart          # Inter font text theme
        app_theme.dart               # Material 3 ThemeData with all component
                                     #   styling (cards, buttons, inputs, nav)

    core/
      constants/
        app_constants.dart           # Upload limits, email domain, etc.
      errors/
        failures.dart                # Failure types + Result<Either> typedef
      network/
        supabase_client_provider.dart # Provider<SupabaseClient>
      services/
        auth_service.dart            # Thin wrapper around Supabase Auth +
                                     #   validation helpers
      providers/
        auth_state_provider.dart     # authServiceProvider, authStateProvider,
                                     #   currentUserProvider
        dashboard_refresh_provider.dart  # Notifier<int> signal for auto-refresh

    features/
      auth/
        data/
          datasources/
            auth_remote_datasource.dart
          models/
            user_model.dart
          repositories/
            auth_repository_impl.dart
        domain/
          entities/
            user.dart
          repositories/
            auth_repository.dart
          usecases/
            sign_in.dart
            sign_up.dart
            sign_out.dart
            get_current_user.dart
        presentation/
          providers/
            auth_controller.dart     # AuthController (AsyncNotifier<User?>)
          screens/
            login_screen.dart
            signup_screen.dart

      dashboard/
        presentation/
          providers/
            dashboard_controller.dart # DashboardData entity + dashboardProvider
                                     #   (FutureProvider, watches refresh signal)
          screens/
            dashboard_home.dart      # Stat cards + notification badge
            student_shell.dart       # Shell with AppBar, 5-tab nav, More menu

      checklist/
        data/
          datasources/
            checklist_remote_datasource.dart
          models/
            checklist_item_model.dart
          repositories/
            checklist_repository_impl.dart
        domain/
          entities/
            checklist_item.dart
          repositories/
            checklist_repository.dart
          usecases/
            load_checklist.dart
            toggle_item.dart
        presentation/
          providers/
            checklist_controller.dart # ChecklistController (AsyncNotifier)
          screens/
            checklist_screen.dart    # Progress bar + toggle tiles

      jobs/
        data/
          datasources/
            job_remote_datasource.dart
          models/
            job_application_model.dart
          repositories/
            job_repository_impl.dart
        domain/
          entities/
            job_application.dart
          repositories/
            job_repository.dart
          usecases/
            load_applications.dart
            add_application.dart
            update_application.dart
            delete_application.dart
        presentation/
          providers/
            job_controller.dart      # JobController (AsyncNotifier)
          screens/
            jobs_screen.dart         # List + add/edit bottom sheet + delete

      my_documents/
        data/
          datasources/
            document_remote_datasource.dart
          models/
            document_model.dart
          repositories/
            document_repository_impl.dart
        domain/
          entities/
            document_item.dart
          repositories/
            document_repository.dart
          usecases/
            load_documents.dart
            upload_document.dart
            delete_document.dart
            get_view_url.dart
        presentation/
          providers/
            document_controller.dart  # DocumentController (AsyncNotifier)
          screens/
            my_documents_screen.dart  # List + upload/view/delete

      logbook/
        data/
          datasources/
            logbook_remote_datasource.dart
          repositories/
            logbook_repository_impl.dart
        domain/
          entities/
            logbook_week.dart
          repositories/
            logbook_repository.dart
          usecases/
            load_weeks.dart
            toggle_submitted.dart
        presentation/
          providers/
            logbook_controller.dart  # LogbookController (AsyncNotifier)
          screens/
            logbook_screen.dart      # Week list with submit toggle

      notifications/
        data/
          datasources/
            notification_remote_datasource.dart
          models/
            notification_model.dart
          repositories/
            notification_repository_impl.dart
        domain/
          entities/
            app_notification.dart
          repositories/
            notification_repository.dart
          usecases/
            load_notifications.dart
            mark_as_read.dart
            delete_notification.dart
        presentation/
          providers/
            notification_controller.dart  # NotificationController (AsyncNotifier)
          screens/
            notification_screen.dart  # Grouped list + swipe-to-delete

      chatbot/
        data/
          datasources/
            chat_remote_datasource.dart
          models/
            chat_session_model.dart
            chat_message_model.dart
          repositories/
            chat_repository_impl.dart
        domain/
          entities/
            chat_session.dart
            chat_message.dart
          repositories/
            chat_repository.dart
          usecases/
            load_sessions.dart
            send_message.dart
        presentation/
          providers/
            chat_controller.dart     # SessionsNotifier + ChatController
          screens/
            chatbot_screen.dart      # Message bubbles + drawer + input

      profile/
        data/
          datasources/
            profile_remote_datasource.dart
          repositories/
            profile_repository_impl.dart
        domain/
          entities/
            student_profile.dart
          repositories/
            profile_repository.dart
        presentation/
          providers/
            profile_controller.dart  # ProfileController (AsyncNotifier)
          screens/
            profile_screen.dart      # View/edit with initials avatar

      settings/
        presentation/
          screens/
            settings_screen.dart     # App version + sign out with confirmation
```

---

## 7. Environment & Configuration

### `.env` file (gitignored)

```env
SUPABASE_URL=https://yyqoleelprtldlvvizdk.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```

Loaded via `flutter_dotenv` at app startup in `main.dart`. Both values are validated — if missing, the app throws `StateError` at startup.

---

## 8. Authentication & Authorization

### Sign-Up Validation

| Field | Rules |
|-------|-------|
| Email | Must end with `@s.unikl.edu.my` (case-insensitive) |
| Student ID | Exactly 11 numeric digits |
| Phone | 9–12 numeric digits |
| Password | Minimum 6 characters |
| Confirm Password | Must match password |

### Role Model

User role is stored in `public.users.role` with check constraint: `student`, `coordinator`, or `super_coordinator`. The mobile app only handles **student** accounts. Admins/coordinators use the web dashboard.

### Auth Flow

| Action | Implementation |
|--------|----------------|
| Sign in | `AuthService.signInWithEmail()` → `supabase.auth.signInWithPassword()` |
| Sign up | `AuthService.signUpStudent()` → `supabase.auth.signUp()` with `user_metadata` containing role + student_id + phone |
| Sign out | `AuthService.signOut()` |
| Session check | `authService.currentUser` (from `Supabase.instance.client.auth.currentSession`) |
| Auth stream | `authService.authStateChanges` → Riverpod `authStateProvider` (StreamProvider) |

### Auth Routing (GoRouter redirect)

```
Not logged in → /login (or /signup)
Logged in → /dashboard
Trying to access /login while logged in → redirected to /dashboard
Trying to access /dashboard while logged out → redirected to /login
```

---

## 9. Routing Table

| Path | Screen | Access | Notes |
|------|--------|--------|-------|
| `/login` | `LoginScreen` | Public | GoRouter redirect target if not logged in |
| `/signup` | `SignupScreen` | Public | GoRouter route |
| `/dashboard` | `DashboardHome` | Auth | Tab 0 in StatefulShellRoute |
| `/checklist` | `ChecklistScreen` | Auth | Tab 1 in StatefulShellRoute |
| `/jobs` | `JobsScreen` | Auth | Tab 2 in StatefulShellRoute |
| `/chat` | `ChatbotScreen` | Auth | Tab 3 in StatefulShellRoute |
| `/my-documents` | `MyDocumentsScreen` | Auth | Pushed from More menu (not a tab) |
| `/notifications` | `NotificationScreen` | Auth | Pushed from AppBar bell or More menu |
| `/logbook` | `LogbookScreen` | Auth | Pushed from More menu |
| `/profile` | `ProfileScreen` | Auth | Pushed from More menu |
| `/settings` | `SettingsScreen` | Auth | Pushed from More menu |

Bottom nav has **5 items** (4 tabs + More icon). The More icon opens a modal bottom sheet with: Weekly Logbook, Notifications, Documents, Profile, Settings, and Logout.

---

## 10. Feature Deep Dives

### 10.1 Dashboard

- **Screen:** `DashboardHome` (ConsumerWidget with RefreshIndicator)
- **Provider:** `dashboardProvider` — `FutureProvider<DashboardData>` aggregating data from 4 Supabase tables in parallel, plus the student's semester dates
- **Tables:** `student_checklists`, `job_applications`, `digital_wallet_items`, `weekly_logbook_tracking`, `semesters` (via `student_semesters`)
- **UI:** Welcome greeting, then an **INTRA Journey card** with two stages:
  - *Preparation* — milestone progress, tap through to Checklist
  - *Internship* — date-driven 14-week strip (submitted / current / missed / upcoming), `Week N of 14`, counts and next deadline, tap through to Logbook
  - Below it, Applications and Documents stat tiles
- **Journey logic:** `computeJourneyProgress` in `presentation/journey_progress.dart` — pure, unit tested; a week is not missed on its due date
- **Auto-refresh:** Watches `dashboardRefreshProvider` — a `Notifier<int>` bumped by every feature controller after mutations (toggle checklist, add job, upload document, submit logbook, etc.)
- **States:** loading spinner, error card with retry, data with journey card + 2 stat tiles
- **Each stage/card is tappable** — navigates to the relevant feature

### 10.2 Checklist

- **Screen:** `ChecklistScreen` (ConsumerWidget)
- **Provider:** `checklistControllerProvider` — `AsyncNotifier<List<ChecklistItem>>`
- **Tables:** `student_semesters`, `semesters`, `checklist_templates`, `student_checklists`
- **Logic:**
  1. Find student's enrolled semester (or active semester)
  2. Load `checklist_templates` for that semester, ordered by `display_order`
  3. Fetch the student's existing `student_checklists` rows in **one** query, then batch-create any missing ones (lazy creation)
  4. Display with toggle completion
- **Optimistic update:** Toggle flips immediately in local state, then persists to Supabase
- **States:** loading, error with retry, empty, data with progress bar + card tiles

### 10.3 Job Applications

- **Screen:** `JobsScreen` (ConsumerWidget)
- **Provider:** `jobControllerProvider` — `AsyncNotifier<List<JobApplication>>`
- **Table:** `job_applications`
- **Status values (DB enum):** `Pending`, `Interview`, `Offer`, `Rejected`, `Accepted`
- **UI:** List with status chip colors, FAB to add, add/edit via modal bottom sheet, delete via popup menu with confirmation dialog
- **States:** loading, error with retry, empty with prompt, data with RefreshIndicator
- **Inline date formatting** (no intl package dependency)

### 10.4 Chatbot

- **Screen:** `ChatbotScreen` (ConsumerStatefulWidget)
- **Providers:**
  - `sessionsProvider` — `AsyncNotifier<List<ChatSession>>`
  - `messagesProvider(sessionId)` — `FutureProvider.family<List<ChatMessage>, String>`
  - `chatControllerProvider` — `Provider<ChatController>` (helper class with `sendMessage`)
- **Tables:** `chat_sessions`, `chat_messages`, `faqs`
- **FAQ matching:** Rule-based scoring (no external LLM):
  - +10 if user message contains FAQ title
  - +5 per matching keyword
  - +1 per word overlap (words > 3 chars)
  - Best match returned as assistant response; fallback message if no match
- **UI:** Message bubbles with role-based styling, end drawer for session history, text input bar with send button
- **Auto-initialization:** Loads latest session on app start, or creates a new one

### 10.5 My Documents

- **Screen:** `MyDocumentsScreen` (ConsumerWidget)
- **Provider:** `documentControllerProvider` — `AsyncNotifier<List<DocumentItem>>`
- **Table:** `digital_wallet_items`
- **Storage bucket:** `student-documents`
- **Upload:** Supports `image_picker` (gallery) + `file_picker` (any file), 5 MB limit. Gallery picks are resized to max 2000 px at quality 85 before upload
- **Storage path (object key):** `{userId}/{timestamp}.{ext}` — the bucket name is not part of the key
- **Preview:** Downloads the bytes through the authenticated client (no signed URL) and renders PDFs in-app with `pdfx`; images render with `Image.memory`
- **Rename:** Updates the document's display name (the stored object key stays unchanged)
- **Download:** Saves the file to the device through the system "Save to…" picker (SAF on Android) — no storage permission required
- **Delete:** Removes both storage file and DB row (with confirmation dialog)
- **States:** loading, error, empty, data with file type icons (PDF red, DOC blue, image green, etc.)
- **Upload flow:** Choose source → pick file → name dialog → upload

### 10.6 Notifications

- **Screen:** `NotificationScreen` (ConsumerWidget)
- **Provider:** `notificationControllerProvider` — `AsyncNotifier<List<AppNotification>>`
- **Table:** `notifications` — personal messages plus one per-student copy of each broadcast
- **Broadcasts:** `broadcast_messages` stays the source of truth. Database triggers fan a copy out to every student when `target_roles` includes `students_all`, sync title/body/images when the broadcast is edited, and delete the copies when the broadcast is deleted.
- **Images:** broadcast images are copied into `image_paths`; the card shows up to three thumbnails (public `broadcast-media` bucket) and opens a zoomable full-screen viewer.
- **Logic:** Loading never mutates read state. Unread items show a dot + bold title; the shell bell shows an unread-count badge. Tapping an item marks it read; "Mark all read" clears the rest. Swipe-to-archive sets `archived_at` after the server confirms; a failed archive keeps the row with a SnackBar. Archived rows are filtered out of the inbox but retained for INTRA delivery records. Live updates arrive via Supabase Realtime (Postgres Changes on `notifications`, filtered by `recipient_id`), so new broadcasts update the badge without restarting the app.
- **Grouping:** Today / This Week / Earlier (computed locally from `created_at`)
- **Archive read:** app-bar overflow action archives every read notification in one call (unread items are kept), with a confirmation dialog and a count in the SnackBar. Rows are retained with `archived_at` for the INTRA office; nothing is hard-deleted by students.
- **Coordinator access:** coordinators can select broadcast copies (including read/archived state) for delivery records; personal notifications remain private to their recipient.
- **States:** loading, error, empty ("You're all caught up!"), grouped list

### 10.7 Logbook

- **Screen:** `LogbookScreen` (ConsumerStatefulWidget, refreshes on resume)
- **Provider:** `logbookControllerProvider` — `AsyncNotifier<List<LogbookWeek>>`
- **Table:** `weekly_logbook_tracking`
- **UI:** Header card with `Week N of 14`, submitted count and progress. Week cards are date-aware via `buildLogbookSummary`:
  - **submitted** (teal, undo action)
  - **current** (blue, "This week")
  - **due soon** (amber, within 3 days)
  - **overdue** (red; late weeks stay submittable)
  - **upcoming** (grey, locked — future weeks cannot be marked)
- **Submission:** explicit `Mark` with a confirmation explaining the app does not upload the logbook; optimistic update with rollback on failure
- **States:** loading, error, empty, data

### 10.8 Profile

- **Screen:** `ProfileScreen` (ConsumerStatefulWidget)
- **Provider:** `profileControllerProvider` — `AsyncNotifier<StudentProfile>`
- **Table:** `users`
- **UI:** Initials avatar, view/edit toggle with form fields (full name, phone number)
- **Actions:** Edit, Save, Cancel — all inline with no separate navigation
- **States:** loading, error, data with read-only fields or edit form

### 10.9 Settings

- **Screen:** `SettingsScreen` (ConsumerWidget)
- **Provider:** Uses `authControllerProvider` for sign out
- **UI:** List with app version, sign out with confirmation dialog
- **Actions:** Sign out clears session and redirects to `/login`

---

## 11. State Management Inventory

| Provider | Type | Returns | Key Methods |
|----------|------|---------|-------------|
| `supabaseClientProvider` | `Provider` | `SupabaseClient` | — |
| `authServiceProvider` | `Provider` | `AuthService` | — |
| `authStateProvider` | `StreamProvider` | `Stream<AuthState>` | — |
| `currentUserProvider` | `Provider` | `User?` | — |
| `appRouterProvider` | `Provider` | `GoRouter` | — |
| `dashboardRefreshProvider` | `NotifierProvider` | `int` | `trigger()` (bumps counter) |
| `dashboardProvider` | `FutureProvider` | `DashboardData` | — (watches refresh signal) |
| `checklistControllerProvider` | `AsyncNotifierProvider` | `List<ChecklistItem>` | `toggleItem(id, bool)` |
| `jobControllerProvider` | `AsyncNotifierProvider` | `List<JobApplication>` | `add/update/delete()` |
| `documentControllerProvider` | `AsyncNotifierProvider` | `List<DocumentItem>` | `upload/delete()` |
| `logbookControllerProvider` | `AsyncNotifierProvider` | `List<LogbookWeek>` | `toggleSubmitted(id, bool)` |
| `notificationControllerProvider` | `AsyncNotifierProvider` | `List<AppNotification>` | `markAsRead(id)`, `deleteNotification(id)` |
| `sessionsProvider` | `AsyncNotifierProvider` | `List<ChatSession>` | `findOrCreateSession()` |
| `messagesProvider(sessionId)` | `FutureProvider.family` | `List<ChatMessage>` | — |
| `chatControllerProvider` | `Provider` | `ChatController` | `sendMessage(sessionId, content)` |
| `profileControllerProvider` | `AsyncNotifierProvider` | `StudentProfile` | `updateProfile(name, phone)` |
| `authControllerProvider` | `AsyncNotifierProvider` | `User?` | `signIn/signUp/signOut` |
| `checklistRepositoryProvider` | `Provider` | `ChecklistRepository` | — |
| `jobRepositoryProvider` | `Provider` | `JobRepository` | — |
| `documentRepositoryProvider` | `Provider` | `DocumentRepository` | — |
| `logbookRepositoryProvider` | `Provider` | `LogbookRepository` | — |
| `notificationRepositoryProvider` | `Provider` | `NotificationRepository` | — |
| `chatRepositoryProvider` | `Provider` | `ChatRepository` | — |
| `profileRepositoryProvider` | `Provider` | `ProfileRepository` | — |
| `authRepositoryProvider` | `Provider` | `AuthRepository` | — |

All providers are defined manually (no Riverpod code generation). Repository providers are `Provider<T>` singletons. Feature controllers are `AsyncNotifierProvider`. The dashboard uses `FutureProvider` with a refresh signal.

---

## 12. Database Schema

[Sections 12.1–12.5 unchanged — same schema as originally defined]

### 12.1 Public Tables

#### `users`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | uuid | PK, FK → auth.users.id | |
| email | text | NULL | |
| full_name | text | NOT NULL | |
| student_id | text | UNIQUE, NULL | |
| phone_number | text | NULL | |
| role | text | NOT NULL, CHECK (student, coordinator, super_coordinator) | |
| avatar_url | text | NULL | |
| created_at | timestamptz | NULL | now() |
| updated_at | timestamptz | NULL | now() |

#### `semesters`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| name | text | NOT NULL | |
| start_date | date | NOT NULL | |
| end_date | date | NOT NULL | |
| is_active | boolean | NULL | false |
| created_at | timestamptz | NULL | now() |

#### `student_semesters`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| student_id | uuid | FK → users.id | |
| semester_id | int4 | FK → semesters.id | |
| enrolled_at | timestamptz | NULL | now() |

#### `checklist_templates`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| title | text | NOT NULL | |
| description | text | NULL | |
| required | boolean | NULL | true |
| display_order | int4 | NULL | |
| semester_id | int4 | FK → semesters.id | |
| created_at | timestamptz | NULL | now() |

#### `student_checklists`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| student_id | uuid | FK → users.id | |
| checklist_item_id | int4 | FK → checklist_templates.id | |
| is_completed | boolean | NULL | false |
| completed_at | timestamptz | NULL | |
| due_date | date | NULL | |
| notes | text | NULL | |
| override_reason | text | NULL | |
| updated_by_admin | uuid | FK → users.id, NULL | |

#### `job_applications`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| student_id | uuid | FK → users.id | |
| company_name | text | NOT NULL | |
| position | text | NULL | |
| application_date | date | NULL | CURRENT_DATE |
| status | application_status | NULL | 'Pending' |
| notes | text | NULL | |
| created_at | timestamptz | NULL | now() |
| updated_at | timestamptz | NULL | now() |
| override_reason | text | NULL | |
| updated_by_admin | uuid | FK → users.id, NULL | |

**Enum `application_status`:** `Pending`, `Interview`, `Offer`, `Rejected`, `Accepted`

#### `digital_wallet_items`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| student_id | uuid | FK → users.id | |
| item_name | text | NOT NULL | |
| file_path | text | NOT NULL | |
| file_type | text | NULL | |
| uploaded_at | timestamptz | NULL | now() |
| notes | text | NULL | |

#### `weekly_logbook_tracking`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| student_id | uuid | FK → users.id | |
| semester_id | int4 | FK → semesters.id | |
| week_number | int4 | NOT NULL | |
| week_end_date | date | NOT NULL | |
| is_submitted | boolean | NULL | false |
| submitted_at | timestamptz | NULL | |
| reminder_sent | boolean | NULL | false |
| created_at | timestamptz | NULL | now() |
| updated_at | timestamptz | NULL | now() |

#### `faq_categories`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| name | text | NOT NULL | |
| description | text | NULL | |
| display_order | int4 | NULL | |

#### `faqs`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| category_id | int4 | FK → faq_categories.id | |
| question | text | NOT NULL | |
| answer | text | NOT NULL | |
| keywords | text[] | NULL | |
| is_published | boolean | NULL | true |
| created_by | uuid | FK → users.id | |
| updated_at | timestamptz | NULL | now() |

#### `notifications`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| recipient_id | uuid | FK → users.id | |
| title | text | NULL | |
| body | text | NULL | |
| type | text | NULL | |
| is_read | boolean | NULL | false |
| created_at | timestamptz | NULL | now() |
| scheduled_for | timestamptz | NULL | |
| broadcast_id | int8 | FK → broadcast_messages.id | |
| image_paths | text[] | NOT NULL | '{}' |
| archived_at | timestamptz | NULL | |

#### `broadcast_messages`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| coordinator_id | uuid | FK → users.id | |
| title | text | NULL | |
| body | text | NULL | |
| target_roles | text[] | NULL | |
| sent_at | timestamptz | NULL | now() |
| image_paths | text[] | NOT NULL | '{}' |

#### `chat_sessions`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| student_id | uuid | FK → users.id, NOT NULL | |
| title | text | NULL | |
| created_at | timestamptz | NULL | now() |
| updated_at | timestamptz | NULL | now() |

#### `chat_messages`
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int8 | PK | sequence |
| session_id | uuid | FK → chat_sessions.id, NOT NULL | |
| role | text | NOT NULL, CHECK (user, assistant) | |
| content | text | NOT NULL | |
| matched_faq_id | int4 | FK → faqs.id, NULL | |
| created_at | timestamptz | NULL | now() |

### 12.2 Entity Relationships

```
auth.users (1) ──→ users (1) ──→ student_semesters (N) ──→ semesters (1)
                                      │
                                      ├── student_checklists (N) ──→ checklist_templates (N) ──→ semesters (1)
                                      ├── job_applications (N)
                                      ├── weekly_logbook_tracking (N) ──→ semesters (1)
                                      ├── digital_wallet_items (N)
                                      ├── notifications (N) ──→ broadcast_messages (1)
                                      └── chat_sessions (N) ──→ chat_messages (N) ──→ faqs (1) ──→ faq_categories (1)
```

### 12.3 Enums

| Enum Name | Values |
|-----------|--------|
| `application_status` | `Pending`, `Interview`, `Offer`, `Rejected`, `Accepted` |

### 12.4 Auth Schema

Standard Supabase Auth schema (`auth.users`, `auth.sessions`, `auth.refresh_tokens`, `auth.identities`, etc.). The key relationship is `public.users.id` → `auth.users.id`.

### 12.5 Storage

- **Bucket:** `student-documents`
- **Path pattern (object key):** `{userId}/{timestamp}.{ext}` — bucket name is not included
- **Access:** authenticated downloads through the Storage API; no signed URLs

- **Bucket:** `broadcast-media` (public)
- **Path pattern:** `broadcast-images/{coordinatorId}/{uuid}.{ext}`
- **Access:** public URLs, used for broadcast image thumbnails in the notification inbox

---

## 13. Design System / Theme

The app uses **Material 3** with a custom light theme.

### Color Palette (current implementation)

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#1D4ED8` | AppBar, FilledButton, active nav |
| Primary Container | `#DBEAFE` | Active chip backgrounds, selection |
| Secondary | `#0D9488` | Checkboxes, success states, FAB |
| Secondary Container | `#CCFBF1` | Chip backgrounds |
| Tertiary / Accent | `#F59E0B` | Milestone highlights, badges |
| Tertiary Container | `#FEF3C7` | Badge backgrounds |
| Background | `#F8FAFC` | Scaffold background |
| Surface | `#FFFFFF` | Cards, inputs, sheets |
| On Surface | `#1E293B` | Primary text |
| Muted Text | `#64748B` | Secondary text |
| Error | `#EF4444` | Error states |
| Border | `#E2E8F0` | Dividers, input borders |

### Typography

- **Font:** Inter (Google Fonts, via `google_fonts` package)
- **Scale:** 32pt → 12pt across 8 text styles, all Inter with varying weight

### Notable Widgets

| Component | Styling |
|-----------|---------|
| Cards | `surface` color, 16px radius, elevation 1, subtle shadow |
| Buttons | Primary `#1D4ED8` with white text, 12px radius |
| Inputs | Outlined border, `surface` fill, 12px radius |
| Bottom nav | Material 3 NavigationBar, 5 items + indicator |
| AppBar | Surface color, no elevation, centered title |

---

## 14. Current State & Known Issues

### Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (login/signup) | Complete | Email/password, validation rules, GoRouter redirect |
| Dashboard | Complete | Auto-refresh via signal, tappable stat cards |
| Checklist | Complete | Lazy row creation, optimistic toggle |
| Job Applications | Complete | DB enum statuses, CRUD with bottom sheet |
| My Documents | Complete | Gallery/file upload, in-app preview, download, rename, delete |
| Weekly Logbook | Complete | Submit/unsubmit with progress bar |
| Notifications | Complete | Grouped list, swipe-to-delete, auto-mark-read |
| Chatbot | Complete | Rule-based FAQ matching, session history drawer |
| Profile | Complete | View/edit name and phone |
| Settings | Complete | App version, sign out with confirmation |

### Known Issues

1. **Direct Supabase access in auth_service:** `AuthService` calls `Supabase.instance.client` directly, making it harder to mock in tests.
2. **`authService.currentUser!` null risk:** `currentUser!` will crash if the session expires while the user is on a screen that reads it (e.g., any data source's `_userId` getter).
3. **No autoDispose on providers:** All providers live in memory permanently since none use `.autoDispose`. Acceptable for current app size.
4. **Riverpod code generation not used:** Manual provider declarations are used instead of `@riverpod` annotations, resulting in more boilerplate.
5. **Inconsistent controller patterns:** Some features use `AsyncValue.guard` (checklist, logbook), others use `fold()` + `invalidateSelf()` (jobs, documents). Both work but aren't uniform.
6. **`ChatController` uses manual `Ref`:** Instead of extending `AsyncNotifier`, it stores `Ref` as a field — less idiomatic Riverpod.
7. **Test coverage is partial:** auth (incl. error mapping), notifications (controller, repository, bell widget), jobs and profile controllers are covered (~53 tests). Checklist, logbook, documents, dashboard and router redirects still have no tests.
8. **`dio` and `intl` unused:** Dependencies are imported but not used anywhere in the codebase.

---

## 15. Running the App

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code
dart run build_runner build

# Create environment file (if not present)
echo "SUPABASE_ANON_KEY=your_key" >> .env

# Run on connected device / emulator
flutter run
```

### Code Generation

```bash
# One-time build
dart run build_runner build

# Watch mode (auto-regenerate on changes)
dart run build_runner watch
```

### Linting & Analysis

```bash
flutter analyze
dart format .
```
