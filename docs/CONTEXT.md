# INTRA Buddy Mobile — System Summary & Rebuild Blueprint

---

## 1. Project Identity & Purpose

| Field | Value |
|-------|-------|
| **Name** | `intra_buddy_mobile` |
| **Version** | `0.1.0+1` |
| **Description** | Student-facing mobile app for UniKL internship management |
| **Platform** | Flutter (iOS, Android, web, desktop) |
| **Primary audience** | UniKL students enrolled in industrial training (INTRA) |

**Purpose:** Help students track internship tasks — milestone checklists, job applications, weekly logbook submissions(status only not a place to submit the logbooks), document wallet, notifications, and a FAQ-based chatbot assistant.

---

## 2. Scope & Boundaries

This is a **two-person team project** with a shared Supabase backend:

| Component | Repo | Responsibility | Built by |
|-----------|------|----------------|----------|
| Mobile App | `intra_buddy_mobile` | Student-facing features | You |
| Web Dashboard | (separate repo) | Admin/coordinator tools | Teammate |

**In scope (mobile app):**
- Student auth (email/password via Supabase Auth)
- Dashboard with progress overview
- INTRA milestone checklist
- Job application tracker
- FAQ-based chatbot assistant
- Digital wallet (document uploads) *need to change the Digital Wallet name to something else, not sure yet*
- Notifications inbox
- Weekly logbook status

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
| `riverpod_annotation` | ^4.0.2 | Riverpod code generation |
| `hooks_riverpod` | ^3.3.1 | Hooks + Riverpod integration |
| `go_router` | ^17.2.3 | Declarative routing |
| `dio` | ^5.5.0 | HTTP client (file uploads) |
| `dartz` | ^0.10.1 | Functional programming (Either monad) |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `intl` | ^0.20.2 | Date formatting |
| `image_picker` | ^1.1.0 | Camera/gallery for document upload |
| `file_picker` | ^11.0.2 | File picker for document upload |
| `url_launcher` | ^6.3.1 | Open signed URLs externally |
| `flutter_dotenv` | ^6.0.1 | Environment variables from `.env` |
| `google_fonts` | ^6.2.1 | Google Fonts (Baloo 2) |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `riverpod_generator` | ^4.0.0 | Riverpod code generation |
| `build_runner` | ^2.4.0 | Code generation runner |
| `riverpod_lint` | ^3.1.3 | Riverpod-specific linting |

### Architecture Decisions

- **State management:** Riverpod with code generation (`@riverpod` + `.g.dart`)
- **Routing:** GoRouter with `StatefulShellRoute.indexedStack` for bottom nav persistence
- **Backend:** Supabase PostgreSQL + Auth + Storage + Realtime
- **Auth:** Email/password only (no OAuth)
- **Chatbot:** Rule-based FAQ matching (no external LLM API)
- **Theme:** Material 3, warm/light color scheme, Baloo 2 font

---

## 5. Architecture Overview

### Layered Architecture

```
lib/
  main.dart                           # Entry point, Supabase init, theme, router
  src/
    core/
      services/auth_service.dart       # Auth wrapper (singleton)
      routing/app_router.dart          # GoRouter config + auth redirect
      providers/                       # Shared providers
        supabase_client_provider.dart  # SupabaseClient provider
        auth_service_provider.dart     # AuthService provider
        auth_state_provider.dart       # Reactive auth stream
    features/
      {feature}/
        providers/                     # AsyncNotifier providers per feature
        {screen}.dart                  # UI (ConsumerWidget / ConsumerStatefulWidget)
```

### Data Flow

```
UI (ConsumerWidget)
  └─ watches provider
       └─ provider calls Supabase.instance.client directly
            └─ returns AsyncValue<T>
                 └─ UI renders with .when(loading, error, data)
```

**Notable pattern:** Most providers call `Supabase.instance.client` directly and `AuthService().currentUser!.id` directly, rather than injecting through Riverpod providers. This makes testing harder but keeps the code simple.

### Navigation Flow

```
Auth check (GoRouter redirect)
  ├─ Not logged in → /login or /signup
  └─ Logged in → /dashboard (StatefulShellRoute)
       ├─ /dashboard      (tab 0 — DashboardHome)
       ├─ /checklist      (tab 1 — ChecklistScreen)
       ├─ /jobs           (tab 2 — JobsScreen)
       ├─ /chat           (tab 3 — ChatbotScreen)
       └─ /wallet         (tab 4 — WalletScreen)
  ── /notifications (pushed from AppBar bell icon)
  ── /logbook       (pushed from More menu)
```

---

## 6. Complete Project Structure

```
lib/
  main.dart
  src/
    core/
      providers/
        auth_service_provider.dart
        auth_service_provider.g.dart
        auth_state_provider.dart
        auth_state_provider.g.dart
        supabase_client_provider.dart
        supabase_client_provider.g.dart
      routing/
        app_router.dart
      services/
        auth_service.dart
    features/
      auth/
        login_screen.dart
        signup_screen.dart
      dashboard/
        dashboard_home.dart
        student_dashboard.dart
        providers/
          dashboard_provider.dart
          dashboard_provider.g.dart
      checklist/
        checklist_screen.dart
        providers/
          checklist_provider.dart
          checklist_provider.g.dart
      chatbot/
        chatbot_screen.dart
        providers/
          chat_messages_provider.dart
          chat_messages_provider.g.dart
          chat_sessions_provider.dart
          chat_sessions_provider.g.dart
      digital_wallet/
        wallet_screen.dart
        providers/
          wallet_provider.dart
          wallet_provider.g.dart
      jobs/
        jobs_screen.dart
        providers/
          jobs_provider.dart
          jobs_provider.g.dart
      logbook/
        logbook_detail_page.dart
        providers/
          logbook_provider.dart
          logbook_provider.g.dart
      notifications/
        notification_screen.dart
        providers/
          notifications_provider.dart
          notifications_provider.g.dart
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
| Sign out | `AuthService.signOut()` → `supabase.auth.signOut()` |
| Session check | `Supabase.instance.client.auth.currentSession` |
| Auth stream | `supabase.auth.onAuthStateChange` |
| Role lookup | SELECT role FROM users WHERE id = userId |

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
| `/signup` | `SignupScreen` | Public | Pushed via Navigator, not GoRouter (legacy) |
| `/dashboard` | `DashboardHome` | Auth | Tab 0 in StatefulShellRoute |
| `/checklist` | `ChecklistScreen` | Auth | Tab 1 in StatefulShellRoute |
| `/jobs` | `JobsScreen` | Auth | Tab 2 in StatefulShellRoute |
| `/chat` | `ChatbotScreen` | Auth | Tab 3 in StatefulShellRoute |
| `/wallet` | `WalletScreen` | Auth | Tab 4 in StatefulShellRoute |
| `/notifications` | `NotificationScreen` | Auth | Pushed from AppBar bell icon |
| `/logbook` | `LogbookDetailPage` | Auth | Pushed from More menu in bottom sheet |

The bottom nav has **6 items** (tabs 0–4 + a More `Icons.more_horiz` that opens a modal bottom sheet). The More menu contains: Weekly Logbook Status, Profile (coming soon), Settings (coming soon), and Logout.

---

## 10. Feature Deep Dives

### 10.1 Dashboard

- **Screen:** `DashboardHome` (ConsumerWidget)
- **Provider:** `dashboardProvider` — async map aggregating data from 5 Supabase tables
- **Tables:** `users`, `student_checklists`, `job_applications`, `weekly_logbook_tracking`, `digital_wallet_items`
- **UI:** Greeting card, milestone progress bar, job app stats, logbook status card, wallet doc count card
- **Theme:** Each card has a different pastel background (amber, blue, orange, purple)
- **Issues:**
    - Queries Supabase directly instead of reusing feature providers
    - Job statuses used by dashboard (`Pending`, `Interview`, `Offer`, `Rejected`) do not match `JobsScreen` statuses (`Applied`, `Interviewed`, `Accepted`, `Rejected`)

### 10.2 Checklist

- **Screen:** `ChecklistScreen` (ConsumerWidget)
- **Provider:** `checklistProvider` (AsyncNotifier)
- **Tables:** `student_semesters`, `semesters`, `checklist_templates`, `student_checklists`
- **Logic:**
    1. Find student's enrolled semester (or active semester)
    2. Load `checklist_templates` for that semester, ordered by `display_order`
    3. Check/create `student_checklists` rows for each template
    4. Display with toggle completion
- **Notable:** Creates `student_checklists` rows lazily (on first load). Toggle updates Supabase and optimistically updates local state.

### 10.3 Job Applications

- **Screen:** `JobsScreen` (ConsumerStatefulWidget)
- **Provider:** `jobsProvider` (AsyncNotifier)
- **Table:** `job_applications`
- **Status values used:** `Applied`, `Interviewed`, `Accepted`, `Rejected`
- **UI:** List with status chips, add/edit via modal bottom sheet, delete via popup menu
- **Notable:** Uses `RefreshIndicator` + retry/error states

### 10.4 Chatbot

- **Screen:** `ChatbotScreen` (ConsumerStatefulWidget)
- **Providers:** `chatSessionsProvider`, `chatMessagesProvider(sessionId)` (family)
- **Tables:** `chat_sessions`, `chat_messages`, `faqs`
- **FAQ matching:** Rule-based scoring (no external LLM):
    - +10 if user message contains FAQ title
    - +5 per matching keyword
    - +1 per word overlap (words > 3 chars)
    - Best match returned as assistant response
- **UI:** Drawer for session history, message bubbles, typing indicator
- **Notable:** First user message auto-generates session title. Long-press session to delete. No external API calls.

### 10.5 Digital Wallet

- **Screen:** `WalletScreen` (ConsumerWidget)
- **Provider:** `walletProvider` (AsyncNotifier)
- **Table:** `digital_wallet_items`
- **Storage bucket:** `student-documents`
- **Upload:** Supports image_picker (gallery) + file_picker (any file), 5 MB limit
- **Storage path:** `student-documents/{userId}/{timestamp}.{ext}`
- **View:** Generates 60-second signed URL, opens via url_launcher
- **Notable:** Upload logic lives in the screen, not the provider. Delete removes both storage file and DB row.

### 10.6 Notifications

- **Screen:** `NotificationScreen` (ConsumerWidget)
- **Provider:** `notificationsProvider` (AsyncNotifier)
- **Table:** `notifications`
- **Logic:** On load, marks all unread as read. Supports tap-to-read and swipe-to-delete.
- **Grouping:** Today / This week / Earlier
- **Notable:** Optimistic local state updates (not invalidation) for mark-read and delete.

### 10.7 Logbook

- **Screen:** `LogbookDetailPage` (ConsumerWidget)
- **Provider:** `logbookProvider` (AsyncNotifier)
- **Table:** `weekly_logbook_tracking`
- **UI:** List of weeks with submit toggle. Once submitted, shows green checkmark + date; button hidden on submitted items.
- **Notable:** Optimistic local state update after toggle.

---

## 11. State Management Inventory

| Provider | Type | Returns | Key Methods |
|----------|------|---------|-------------|
| `supabaseClientProvider` | Provider | `SupabaseClient` | — |
| `authServiceProvider` | Provider | `AuthService` | — |
| `authStateProvider` | StreamProvider | `Stream<AuthState>` | — |
| `goRouterProvider` | Provider | `GoRouter` | — |
| `dashboardProvider` | AsyncNotifier | `Map<String, dynamic>` | — |
| `checklistProvider` | AsyncNotifier | `List<Map<String, dynamic>>` | `toggleCompletion(item, bool)` |
| `jobsProvider` | AsyncNotifier | `List<Map<String, dynamic>>` | `addApplication()`, `updateApplication()`, `deleteApplication()` |
| `chatSessionsProvider` | AsyncNotifier | `List<Map<String, dynamic>>` | `createSession()`, `updateTitle()`, `touchSession()`, `deleteSession()` |
| `chatMessagesProvider(sessionId)` | AsyncNotifier family | `List<Map<String, dynamic>>` | `addUserMessage()`, `addAssistantMessage()` |
| `walletProvider` | AsyncNotifier | `List<Map<String, dynamic>>` | `deleteItem(id)` |
| `notificationsProvider` | AsyncNotifier | `List<Map<String, dynamic>>` | `markAsRead(id)`, `deleteNotification(id)` |
| `logbookProvider` | AsyncNotifier | `List<Map<String, dynamic>>` | `toggleSubmitted(id, bool)` |

All providers use Riverpod code generation (`@riverpod` + `.g.dart` files via `build_runner`).

---

## 12. Database Schema

### 12.1 Public Tables

#### `users`
Links to `auth.users` via FK. Stores student profile and role.

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
Junction table linking students to semesters.

| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| student_id | uuid | FK → users.id | |
| semester_id | int4 | FK → semesters.id | |
| enrolled_at | timestamptz | NULL | now() |

#### `checklist_templates`
Admin-defined milestone items per semester.

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
Per-student checklist item state.

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

#### `broadcast_messages`

| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | int4 | PK | sequence |
| coordinator_id | uuid | FK → users.id | |
| title | text | NULL | |
| body | text | NULL | |
| target_roles | text[] | NULL | |
| sent_at | timestamptz | NULL | now() |

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
- **Path pattern:** `student-documents/{userId}/{timestamp}.{ext}`
- **Access:** Signed URLs (60-second expiry) for viewing

---

## 13. Design System / Theme

The app uses **Material 3** with a custom warm/light theme.

### Color Palette (current implementation)

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#0F172A` | AppBar, buttons, selected nav item |
| Secondary | `#22A699` | FAB, checkboxes, chips |
| Tertiary / Accent | `#F29727` | (defined but not widely used) |
| Background | `#F7F4EF` | Scaffold background |
| Surface | `#FFFDF9` | Cards, inputs |
| Border | `#E7E2DA` | Dividers, input borders |
| Muted text | `#6B7280` | Secondary text |
| Error | `#E74C3C` | Error states |

### Typography

- **Font:** Baloo 2 (Google Fonts, via `google_fonts` package)
- **Scale:** 32pt → 12pt across 8 text styles, all Baloo 2 with varying weight

### Notable Widgets

| Component | Styling |
|-----------|---------|
| Cards | `surface` color, 20px radius, elevation 2, subtle shadow |
| Buttons | Primary `#0F172A` with white text, 16px radius |
| Inputs | Outlined border, `surface` fill, 16px radius |
| Bottom nav | White pill on `#F7F4EF`, no labels, 6 items |
| AppBar | Primary color, white text, no elevation |

---

## 14. Current State & Known Issues

### Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (login/signup) | Complete | Email/password, validation rules implemented |
| Dashboard | Complete | Aggregates from 5 tables |
| Checklist | Complete | Lazy row creation on first load |
| Job Applications | Complete | Status values mismatch with dashboard |
| Chatbot | Complete | Rule-based FAQ matching, no external API |
| Digital Wallet | Complete | Image/file upload, storage signed URLs |
| Notifications | Complete | Auto-mark-read on load |
| Logbook | Complete | Submit/unsubmit with date tracking |
| Riverpod + GoRouter migration | Complete | All features migrated |
| Profile screen | Not started | Placeholder in More menu |
| Settings screen | Not started | Placeholder in More menu |

### Known Issues

1. **Job status mismatch:** `dashboard_provider.dart` expects statuses `Pending`, `Interview`, `Offer`, `Rejected` but `jobs_screen.dart` uses `Applied`, `Interviewed`, `Accepted`, `Rejected`. The database enum is `Pending`, `Interview`, `Offer`, `Rejected`, `Accepted`.

2. **Direct Supabase access:** Almost all providers call `Supabase.instance.client` directly instead of injecting `supabaseClientProvider`. Similarly, they use `AuthService().currentUser!.id` instead of `authServiceProvider`.

3. **Null-assertion risk:** `AuthService().currentUser!.id` will crash if `currentUser` is null. No null checks.

4. **`supabaseClientProvider` unused:** The `supabaseClientProvider` exists but no provider consumes it.

5. **Upload logic in UI:** The digital wallet upload logic lives in `wallet_screen.dart`, not in the provider.

6. **Legacy Navigator.push:** The signup screen uses `Navigator.push` instead of GoRouter, even though GoRouter handles routing.

### Design Doc Note

There is an aspirational design doc (`docs/DESIGN.md`) inspired by the Runna app — dark-first, Indigo+Lime palette, Sora font, training-plan week strip UI. **This is not reflected in the current implementation**, which uses a warm/light Material 3 theme with Baloo 2.

---

## 15. Rebuild Checklist

Use this to recreate the project from scratch with the help of an AI agent:

### Phase 1: Project Scaffold

- [ ] `flutter create intra_buddy_mobile`
- [ ] Add dependencies to `pubspec.yaml` (see section 4)
- [ ] Run `flutter pub get`
- [ ] Set up `.env` with `SUPABASE_URL` and `SUPABASE_ANON_KEY`

### Phase 2: Core Infrastructure

- [ ] Create `lib/src/core/services/auth_service.dart`
- [ ] Create `lib/src/core/providers/` (supabase, auth service, auth state)
- [ ] Create `lib/src/core/routing/app_router.dart` with GoRouter + auth redirect
- [ ] Set up `lib/main.dart` — Supabase init, ProviderScope, MaterialApp.router, theme
- [ ] Run `dart run build_runner build` to generate `.g.dart` files

### Phase 3: Auth Screens

- [ ] `LoginScreen` with email/password validation
- [ ] `SignupScreen` with all field validations
- [ ] Auth flow test (sign up → sign in → dashboard redirect)

### Phase 4: Dashboard & Navigation

- [ ] `StudentDashboard` with StatefulShellRoute + bottom nav bar
- [ ] `DashboardHome` with aggregated data cards
- [ ] More menu bottom sheet (logbook, profile placeholder, logout)
- [ ] `NotificationScreen` (reached from AppBar)

### Phase 5: Feature Screens (one by one)

- [ ] Checklist (provider + screen)
- [ ] Job Applications (provider + screen)
- [ ] Chatbot (sessions + messages providers + screen + FAQ matching)
- [ ] Digital Wallet (provider + screen + Storage integration)
- [ ] Weekly Logbook (provider + screen)

### Phase 6: Database Setup

- [ ] Create Supabase project or use existing `yyqoleelprtldlvvizdk.supabase.co`
- [ ] Run migrations to create all public tables (see section 12)
- [ ] Set up Row Level Security (RLS) policies
- [ ] Create `student-documents` Storage bucket
- [ ] Enable Supabase Auth (email/password)

### Phase 7: Polish

- [ ] Fix known issues (status mismatch, provider injection)
- [ ] Add profile and settings screens
- [ ] Test all flows end-to-end

---

## 16. Running the App

```bash
# Install dependencies
flutter pub get

# Generate Riverpod code
dart run build_runner build

# Create environment file
cp .env.example .env
# Edit .env with your Supabase credentials

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
