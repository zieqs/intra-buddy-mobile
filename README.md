# INTRA Buddy Mobile

Student-facing mobile app for UniKL internship (INTRA) management.

Built with **Flutter** + **Supabase** + **Riverpod**.

## Features

- **Auth** — 3-step email/password signup with student-domain validation, email confirmation, specific auth error messages
- **Dashboard** — Latest-notification banner plus a date-driven INTRA journey (preparation milestones + 14-week logbook timeline)
- **Checklist** — Personalised milestone checklist with optimistic completion tracking
- **Job Applications** — Track company, position, notes and status (Pending/Interview/Offer/Rejected/Accepted)
- **My Documents** — Upload, in-app PDF/image preview, download, rename and delete via Supabase Storage
- **Weekly Logbook** — Date-aware week states (current, due soon, overdue, upcoming), submit/undo, and local deadline reminders
- **Notifications** — Personal messages and coordinator broadcasts (with images), unread badge, realtime updates, archive-with-retention and "Archive read"
- **Chatbot** — Rule-based FAQ assistant with session history
- **Profile** — View and edit student name and phone number
- **Settings** — App version, sign out, and a debug-only notification test

## Project docs

- `docs/CONTEXT.md` — architecture, schema, feature deep dives and known issues
- `docs/SESSION_HANDOFF.md` — current project state, demo data and next steps

## Architecture

Feature-first Clean Architecture with three layers per feature:

```
feature/
  domain/       — Entities, repository interfaces, use cases (pure Dart)
  data/         — Datasources, models, repository implementations (Supabase)
  presentation/ — Riverpod controllers, screens (UI)
```

**State management:** Riverpod 3 (`AsyncNotifier`, `FutureProvider`, `Notifier`)
**Routing:** GoRouter with `StatefulShellRoute.indexedStack` (4 tabs + More menu)
**Backend:** Supabase PostgreSQL + Auth + Storage

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5
- A Supabase project with the schema from `docs/CONTEXT.md`

### Setup

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code
dart run build_runner build

# Configure environment
cp .env.example .env
# Edit .env with your Supabase URL and anon key

# Run the app
flutter run
```

### Code Quality

```bash
flutter analyze
dart format .
```

## Project Structure

```
lib/
  main.dart
  src/
    app/          — Theme, router, app widget
    core/         — Shared services, providers, constants, errors
    features/     — auth, dashboard, checklist, jobs, my_documents,
                    logbook, notifications, chatbot, profile, settings
```

Each feature follows the same `domain/data/presentation` layout.

## Database

Full schema documented in `docs/CONTEXT.md` (section 12). Key tables:
`users`, `semesters`, `checklist_templates`, `student_checklists`,
`job_applications`, `digital_wallet_items`, `weekly_logbook_tracking`,
`faqs`, `notifications`, `chat_sessions`, `chat_messages`

## Team

| Role | Repo |
|------|------|
| Mobile App (this) | `zieqs/intra-buddy` |
| Web Dashboard | (separate repo — admin/coordinator tools) |
