# INTRA Buddy Mobile — System Summary

---

## 1. Project Identity & Purpose

| Field | Value |
|-------|-------|
| **Name** | `intra_buddy_mobile_v2` |
| **Repository** | `github.com/zieqs/intra-buddy` |
| **Version** | `1.0.0+1` |
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
- Journey home with milestone and weekly progress
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
| `flutter_riverpod` | ^3.3.1 | State management |
| `go_router` | ^17.2.3 | Declarative routing |
| `dartz` | ^0.10.1 | Functional programming (Either monad for Result type) |
| `json_annotation` | ^4.11.0 | JSON serialization |
| `image_picker` | ^1.1.0 | Camera/gallery for document upload |
| `file_picker` | ^11.0.2 | File picker for document upload |
| `url_launcher` | ^6.3.1 | Open external links (mailto) |
| `flutter_dotenv` | ^6.0.1 | Environment variables from `.env` |
| `audioplayers` | ^6.8.1 | Celebration chime |
| `shared_preferences` | ^2.5.6 | Celebration sound preference |
| `pdfx` | ^2.11.0 | In-app PDF rendering (native OS engine) |
| `flutter_local_notifications` | ^22.3.3 | Local logbook reminders |
| `timezone` / `flutter_timezone` | ^0.11 / ^5.1 | Scheduling in the device's local time |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `build_runner` | ^2.4.0 | Code generation runner |
| `riverpod_lint` | ^3.1.3 | Riverpod-specific linting |
| `json_serializable` | ^6.9.4 | JSON code generation |
| `mocktail` | ^1.0.4 | Mocking for tests |
| `fake_async` | ^1.3.3 | Deterministic timers in tests |
| `flutter_launcher_icons` | ^0.14.4 | Launcher icon generation |
| `flutter_native_splash` | ^2.4.8 | Native splash generation |

### Architecture Decisions

- **State management:** Riverpod 3 with manual providers (`Provider`, `AsyncNotifierProvider`, `FutureProvider`, `NotifierProvider`)
- **Architecture:** Feature-first Clean Architecture with `domain/data/presentation` layers per feature. Riverpod controllers orchestrate repository operations directly; there is no separate use-case layer.
- **Routing:** GoRouter with `StatefulShellRoute.indexedStack` for 4-tab bottom nav persistence
- **Backend:** Supabase PostgreSQL + Auth + Storage
- **Auth:** Email/password only (no OAuth)
- **Chatbot:** Rule-based FAQ matching (no external LLM API)
- **Theme:** Material 3 light theme, Royal Blue/Sky/Ink palette with an amber accent, Fredoka display + Nunito body type

---

## 5. Architecture Overview

### Layered Architecture (per feature)

```
feature_name/
  domain/
    entities/         Plain Dart classes (no Flutter, no database)
    repositories/     Abstract interfaces defining operations

  data/
    datasources/      Actual Supabase queries and API calls
    models/           JSON-serializable classes with fromJson/toJson
    repositories/     Implements domain interfaces, maps model ↔ entity

  presentation/
    providers/        Riverpod controllers (AsyncNotifier) that orchestrate the repositories
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
  ├─ Email confirmation → /email-confirmation
  └─ Logged in → StatefulShellRoute (4 tabs)
       ├─ /dashboard  (tab 0 — HomeScreen, the journey)
       ├─ /logbook    (tab 1 — LogbookScreen)
       ├─ /jobs       (tab 2 — JobsScreen)
       └─ /chat       (tab 3 — ChatbotScreen)
  ── /my-documents  (pushed)
  ── /notifications (pushed from the bell)
  ── /profile       (pushed from the avatar)
  ── /settings      (pushed from Profile)
```

The bottom bar is the custom `BuddyDock` with four tabs: Journey (`/dashboard`), Logbook, Jobs and Buddy (`/chat`). Notifications, documents, profile and settings are pushed screens, not tabs.

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
        app_typography.dart          # Fredoka + Nunito text theme
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
                                     #   currentUserProvider, authUserIdProvider
        dashboard_refresh_provider.dart  # Notifier<int> signal for auto-refresh
        tab_index_provider.dart      # selected dock tab
      utils/
        app_logger.dart              # debug-only warning/error logging seam
        coordinator_contact.dart     # coordinator email fallback

    features/
      auth/
        data/          datasource (Supabase Auth), user model, repository impl
        domain/        user entity, auth repository contract
        presentation/  auth controller, login / signup / confirmation screens

      enrollment/
        data/          enrollment datasource, repository impl
        domain/        enrollment entity, pickCurrentEnrollment, repository contract
        presentation/  enrollment gate, providers, semester card

      dashboard/
        presentation/  student_shell.dart — shell with BuddyTopBar + BuddyDock

      journey/
        domain/        Journey model, buildJourney, copy helpers (pure Dart)
        presentation/  journeyProvider, HomeScreen/HomeView, trail chapters and
                       nodes, current-task card, milestone sheet, celebration
                       overlay, chime + haptics

      checklist/
        data/          datasource, merger, model, repository impl
        domain/        checklist item entity, repository contract
        presentation/  checklist controller (its UI is the journey trail)

      jobs/
        data/          datasource, model, repository impl
        domain/        job application entity, repository contract
        presentation/  job controller, jobs screen, form and view widgets

      my_documents/
        data/          datasource, storage path helper, model, repository impl
        domain/        document entity, repository contract
        presentation/  document controller, list screen, preview screen,
                       save-to-device helper

      logbook/
        data/          datasource, repository impl
        domain/        logbook week entity, repository contract
        presentation/  controller, week-state helpers, reminder planner /
                       scheduler / sync, logbook screen and view

      notifications/
        data/          query + realtime datasources, model, repository impl
        domain/        notification entity, repository contract
        presentation/  controller, inbox screen, bell, banner, image strip

      chatbot/
        data/          datasource, models, repository impl
        domain/        entities, matchFaq (pure matcher), repository contract
        presentation/  controller, chat screen, bubbles, composer, drawer,
                       thinking-trace panel

      profile/
        data/          datasource, repository impl
        domain/        student profile entity, repository contract
        presentation/  profile controller and screen

      settings/
        presentation/  settings screen (version, sound toggle, sign out)
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
| Session check | `authService.currentUser` for routing; datasources call `requireUserId()`, which clears a stale session and throws `SessionExpiredException` |
| Auth stream | `authService.authStateChanges` → Riverpod `authStateProvider` (StreamProvider) |

### Onboarding & semester assignment

Students do not choose their semester. The signup screen shows the session the
coordinator has opened for registration (`semesters.registration_open`, read
through the pre-auth `get_open_semester` RPC). The `handle_new_user` trigger
enrolls the new account in that session. If no session is open, signup is
blocked with a "contact your coordinator" message.

The signed-in app is wrapped in an enrollment gate: an account with no
`student_semesters` row sees a pending screen (refresh / contact / sign out)
instead of empty checklist and logbook screens. Students who were briefed for
the next intake sign up while the current session is still running; they are
enrolled in the open session, not the active one.

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
| `/signup` | `SignupScreen` | Public | Registration (blocked when no semester is open) |
| `/email-confirmation` | `EmailConfirmationScreen` | Public | After a successful signup |
| `/dashboard` | `HomeScreen` | Auth | Tab 0 — the journey trail |
| `/logbook` | `LogbookScreen` | Auth | Tab 1 — weekly logbook |
| `/jobs` | `JobsScreen` | Auth | Tab 2 — job applications |
| `/chat` | `ChatbotScreen` | Auth | Tab 3 — FAQ assistant |
| `/my-documents` | `MyDocumentsScreen` | Auth | Pushed from Profile |
| `/notifications` | `NotificationScreen` | Auth | Pushed from the bell |
| `/profile` | `ProfileScreen` | Auth | Pushed from the avatar |
| `/settings` | `SettingsScreen` | Auth | Pushed from Profile |

The bottom bar is the custom `BuddyDock`: four tabs (Journey, Logbook, Jobs, Buddy) plus pushed screens. There is no separate checklist route; milestones live on the journey trail.

---

## 10. Feature Deep Dives

### 10.1 Journey (Home)

- **Screen:** `HomeScreen` (ConsumerStatefulWidget) rendering `HomeView`, with `BuddyTopBar` (brand, streak pill, notification bell, profile avatar)
- **Provider:** `journeyProvider` — `FutureProvider<Journey>`, watching `authUserIdProvider` and `dashboardRefreshProvider`
- **Data:** the student's checklist, logbook weeks and current semester, merged by `buildJourney` in `domain/build_journey.dart`
- **Structure:** three chapters — `before` (preparation milestones), `during` (the 14 logbook weeks) and `after` — with node states `done`, `current`, `open`, `missed` and `locked`
- **UI:**
  - Eyebrow (`WEEK N OF 14`, `GETTING READY`, `WRAPPING UP`), headline and streak copy from `domain/journey_copy.dart`
  - `CurrentTaskCard` for the next action, with a label derived from the node (mark a milestone done, open a week, review)
  - Chaptered trail of `TrailChapter` / `TrailNode` cards; tapping a milestone opens the sheet, tapping a week opens Logbook
  - `CelebrationOverlay` with an optional chime and haptic when a node is completed (sound preference lives in Settings)
- **Side effects:** each journey load re-syncs the local logbook reminders
- **Auto-refresh:** watches `dashboardRefreshProvider`, which feature controllers bump after mutations
- **States:** loading, error with retry, empty ("Your journey starts here"), data with pull-to-refresh

### 10.2 Checklist

- **Screen:** `ChecklistScreen` (ConsumerWidget)
- **Provider:** `checklistControllerProvider` — `AsyncNotifier<List<ChecklistItem>>`
- **Tables:** `student_semesters`, `semesters`, `checklist_templates`, `student_checklists`
- **Logic:**
  1. Find the student's current enrolled semester (never the active semester as a stand-in)
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
- **Manual date formatting** in the UI (no `intl` dependency)

### 10.4 Chatbot

- **Screen:** `ChatbotScreen` (ConsumerStatefulWidget)
- **Providers:**
  - `sessionsProvider` — `AsyncNotifier<List<ChatSession>>`
  - `messagesProvider(sessionId)` — `FutureProvider.family<List<ChatMessage>, String>`
  - `chatControllerProvider` — `NotifierProvider<ChatController, ChatProcessingState>` with `idle → thinking → streaming` phases
- **Tables:** `chat_sessions`, `chat_messages`, `faqs`
- **Sending:** the user message is written first, the FAQ lookup runs, then the answer streams in after a short "thinking" pause and is persisted when streaming completes. `stopStreaming()` finishes an in-flight answer; a second send is ignored while one is processing.
- **FAQ matching:** `matchFaq` in `domain/match_faq.dart` (pure, typed with `FaqEntry`):
  - +10 if the message contains the FAQ question
  - +5 per matching keyword
  - +1 per shared word longer than three characters
  - Best match becomes the assistant reply; a coordinator fallback message is used when nothing matches
- **UI:** Message bubbles with role-based styling, a chat-history drawer, thinking-trace panel, stop button, an empty state with the brand mark and example prompts
- **Coverage:** 16 tests across the matcher, repository and controller
- **Auto-initialization:** Loads the latest session on app start, or creates a new one

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
- **Reminders:** local notifications scheduled for 09:00 the day before each unsubmitted `week_end_date` (`flutter_local_notifications` + `timezone`). Rescheduled whenever the journey or logbook loads (app open, tab switch, mutations) and cancelled when a week is submitted. Tapping opens Logbook. Android uses `POST_NOTIFICATIONS` plus the boot receiver; core library desugaring is enabled for the plugin.
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
- **Providers:** `authControllerProvider` for sign out, `celebrationSoundEnabledProvider` for the chime preference
- **UI:** App version (`1.0.0+1`), celebration sound toggle, sign out with confirmation, and a debug-only "send test notification" action (`kDebugMode` only)
- **Actions:** Sign out clears the session and the router redirects to `/login`

---

## 11. State Management Inventory

| Provider | Type | Returns | Key Methods |
|----------|------|---------|-------------|
| `supabaseClientProvider` | `Provider` | `SupabaseClient` | — |
| `authServiceProvider` | `Provider` | `AuthService` | — |
| `authStateProvider` | `StreamProvider` | `Stream<AuthState>` | — |
| `currentUserProvider` | `Provider` | `User?` | — |
| `authUserIdProvider` | `Provider` | `String?` | — |
| `currentTabIndexProvider` | `NotifierProvider` | `int` | `setIndex(index)` |
| `appRouterProvider` | `Provider` | `GoRouter` | — |
| `dashboardRefreshProvider` | `NotifierProvider` | `int` | `trigger()` (bumps counter) |
| `journeyProvider` | `FutureProvider` | `Journey` | — (watches refresh + auth user) |
| `currentEnrollmentProvider` | `FutureProvider` | `Enrollment?` | — |
| `openSemesterProvider` | `FutureProvider` | `Enrollment?` | — |
| `enrollmentRepositoryProvider` | `Provider` | `EnrollmentRepository` | — |
| `checklistControllerProvider` | `AsyncNotifierProvider` | `List<ChecklistItem>` | `toggleItem(id, bool)` |
| `jobControllerProvider` | `AsyncNotifierProvider` | `List<JobApplication>` | `add/update/delete()` |
| `documentControllerProvider` | `AsyncNotifierProvider` | `List<DocumentItem>` | `upload/delete()` |
| `logbookControllerProvider` | `AsyncNotifierProvider` | `List<LogbookWeek>` | `toggleSubmitted(id, bool)` |
| `notificationControllerProvider` | `AsyncNotifierProvider` | `List<AppNotification>` | `markAsRead(id)`, `markAllAsRead()`, `archiveNotification(id)`, `archiveReadNotifications()` |
| `unreadNotificationCountProvider` | `Provider` | `int` | — |
| `notificationRealtimeProvider` | `Provider` | `NotificationRealtimeSource` | `dispose()` |
| `sessionsProvider` | `AsyncNotifierProvider` | `List<ChatSession>` | `findOrCreateSession()` |
| `messagesProvider(sessionId)` | `FutureProvider.family` | `List<ChatMessage>` | — |
| `chatControllerProvider` | `NotifierProvider` | `ChatProcessingState` | `sendMessage()`, `stopStreaming()`, `completeStreaming()` |
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
| `celebrationSoundEnabledProvider` | `AsyncNotifierProvider` | `bool` | `setEnabled(bool)` |
| `celebrationAudioProvider` | `Provider` | `CelebrationAudio` | — |
| `celebrationFeedbackProvider` | `Provider` | `CelebrationFeedback` | — |
| `logbookReminderSchedulerProvider` | `Provider` | `LogbookReminderScheduler` | `reschedule(weeks)` |

All providers are defined manually (no Riverpod code generation). Repository providers are `Provider<T>` singletons. Feature controllers are `AsyncNotifierProvider`; the journey and enrollment reads are `FutureProvider`s. Mutations bump `dashboardRefreshProvider`, which the journey watches so home stays current.

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
| registration_open | boolean | NOT NULL | false |
| created_at | timestamptz | NULL | now() |

`is_active` marks the session currently running. `registration_open` marks the
session new signups join; at most one semester may have it true (partial unique
index). Coordinators open it on the next intake before briefing that cohort, so
a student who signs up before the current session ends joins the right session.

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
| Page | `#F4F8FF` | Scaffold background |
| Surface | `#FFFFFF` | Cards, inputs, sheets |
| Ice | `#E7F0FF` | Soft fills, inactive chips |
| Blue | `#2563EB` | Primary actions, active nav, links |
| Blue deep | `#1D4ED8` | Pressed/strong blue |
| Sky | `#60A5FA` | Secondary accents |
| Ink | `#0F2A4A` | Primary text |
| Muted | `#5C6F86` | Secondary text (4.84:1 on page) |
| Line | `#DCE8FF` | Dividers, card borders |
| Sun | `#FFC53D` | Milestone highlights, streak flame |
| Alert | `#E5484D` | Errors, overdue states |

### Typography

- **Display:** Fredoka (600 weight) for headlines, section titles and the wordmark
- **Body / UI:** Nunito (400–800) for labels, body copy and buttons
- Both families are bundled in `assets/fonts` (no `google_fonts` dependency)

### Notable Widgets

| Component | Styling |
|-----------|---------|
| Cards | White surface, 20px radius, 1.5px `line` border, soft shadow |
| Buttons | Primary blue, 14px radius, Fredoka/Nunito weight contrast |
| Inputs | Outlined `line` border on white, 14px radius |
| Bottom nav | Custom floating `BuddyDock` card: 4 tabs (Journey / Logbook / Jobs / Buddy), route icons, 10.5px labels, 48dp minimum target |
| Shell header | `BuddyTopBar`: uppercase 12px Fredoka eyebrow, streak pill, bell, avatar |
| Pushed screens | Standard `AppBar` with an 18px Fredoka title |

---

## 14. Current State & Known Issues

### Toolchain

| | |
|---|---|
| Flutter / Dart | 3.47.8 stable / 3.13.7 |
| Xcode | 27.1 |
| iOS deployment target | 15.0 (Xcode 27 minimum) |
| iOS dependencies | Swift Package Manager |
| Android | core library desugaring enabled for `flutter_local_notifications` |
| State / routing | Riverpod 3 (manual providers), GoRouter with `refreshListenable` |

### Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (login/signup) | Complete | 3-step signup, student validation, confirmation screen, mapped errors |
| Journey (home) | Complete | Chaptered trail (milestones + 14 weeks), next-task card, streak copy, celebration overlay |
| Enrollment gate | Complete | Resolves the student's current semester; blocks the app with a pending state when none exists |
| Checklist | Complete | Batched load/insert, optimistic toggle |
| Job Applications | Complete | CRUD with statuses and notes; saves awaited with error feedback |
| My Documents | Complete | Gallery/file upload, in-app preview, download, rename, delete |
| Weekly Logbook | Complete | Date-aware states, confirm/undo, rollback, local deadline reminders |
| Notifications | Complete | Personal + broadcast fan-out with images, archive retention, realtime, badge |
| Chatbot | Complete | Rule-based FAQ matching, streaming answer, session history |
| Profile | Complete | View/edit name and phone, validation |
| Settings | Complete | App version, celebration sound toggle, sign out, debug-only notification test |
| Branding | Complete | Launcher icon + adaptive icon, splash screens, app name, in-app mark |

### Demo data (verified 19 Nov 2026)

- Active semester: **`INTRA Session 1 2026/2027`**, 1 Nov 2026 – 7 Feb 2027 (`is_active = true`, `registration_open = false`).
- 14 logbook weeks ending 8 Nov 2026 → 7 Feb 2027; weeks 1–2 submitted, week 3 in progress.
- Demo account: `hazieq.azrul@s.unikl.edu.my` (email confirmed, enrolled in the active semester).
- 10 checklist items (4 completed), 4 job applications, 2 documents, 6 FAQs.
- 12 notifications, **0 unread** — mark 2–3 unread before a demo so the badge and "archive read" flow are visible.
- Migration backups: `_demo_backup_semesters_20261029`, `_demo_backup_weeks_20261029` — drop once no longer needed.

### Known Issues

1. **No remote push yet:** Android FCM is deferred; iOS push additionally requires a paid Apple Developer Program account (APNs entitlement). Students get local logbook reminders and in-app realtime updates only.
2. **Reminders reschedule only when data loads:** the device plan refreshes when the journey/logbook loads. If semester dates change in the database, reminders correct on the next app open.
3. **No unarchive UI:** archived notifications are retained for INTRA records but students can only see active ones.
4. **No autoDispose on providers:** providers live for the app session. Acceptable at this size; user-scoped providers invalidate on auth changes.
5. **Inconsistent controller patterns:** jobs/documents use `fold()` + `invalidateSelf()`, checklist/logbook use optimistic state. Both work but aren't uniform.
6. **Release APK is debug-signed:** fine for sideloading, rejected by Google Play; needs an upload keystore before publishing.
7. **No integration/E2E tests:** 279 unit and widget tests cover the features, but router + Supabase + storage are never exercised together.
8. **Migration history drift:** seven applied migrations have no file in the repo and seven filenames use different timestamps, so `supabase db push` is unsafe until a baseline is adopted. See `supabase/README.md`.
9. **Two deny-all tables:** `coordinator_student_assignments` and `student_management_audit` have RLS enabled with no policies, so only the service role can read them. Decide with the web dashboard whether that is intended.
10. **`.env` is bundled as a Flutter asset:** only the publishable key lives there, but never add a server secret; it would ship inside the APK.
11. **AuthService injection is partial:** the class accepts an injected client for tests, but providers still construct it from the Supabase singleton.

### Next steps

1. **Android FCM push** (free): Firebase project, `device_tokens` table, `send-push` Edge Function, DB webhooks for `broadcast_messages` and personal `notifications`.
2. **iOS push:** only after an Apple Developer Program account is available.
3. **Database baseline:** `supabase db dump` + `migration repair` per `supabase/README.md`; then reconcile the two RLS-less tables and enable leaked-password protection.
4. **Retention job:** delete archived notifications beyond the retention window when it becomes relevant.
5. **Integration tests:** cover sign-in → journey → logbook submit → notification read against a real backend.

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
