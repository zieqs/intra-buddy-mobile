# Session Handoff

Snapshot of the project state so a new session can start without re-reading the whole history.

## Snapshot

| | |
|---|---|
| Repo | `intra_buddy_mobile_v2` (student-facing Flutter app) |
| Branch | `main`, with the latest branding/auth/cleanup pass uncommitted |
| Last commit | `67476c5 feat(auth): prompt students to confirm their INTRA session` |
| Version | `1.0.0+1` |
| Flutter / Dart | 3.47.8 / 3.13.7 |
| Xcode | 27.1 (iOS minimum 15.0, Swift Package Manager) |
| Verification | 279 tests passing, analyzer clean, release APK builds (debug-signed) |

## Changes since the previous snapshot

- **Branding** — generated launcher icon (adaptive Android + full iOS set), native splash for Android/Android 12/iOS, app name **INTRA Buddy** on both platforms, and the brand mark on the login, signup and chat empty states.
- **Navigation** — the dock is now `Journey · Logbook · Jobs · Buddy`; shell headers are `JOURNEY / LOGBOOK / JOBS`; the chat screen is titled Buddy.
- **Auth** — `AuthService.requireUserId()` replaced every `currentUser!` usage. A missing session clears the stale local session and the router redirects to `/login`. `AuthService` also accepts an injected client for tests.
- **Error visibility** — new `AppLogger`; the 13 silent `catch (_)` sites now log the failure with its stack trace in debug builds.
- **Chatbot** — FAQ matching extracted to `domain/match_faq.dart` (pure, typed with `FaqEntry`); 16 tests cover the matcher, repository and controller.
- **Architecture** — removed the unused `domain/usecases/` layer (20 files, no callers); enrollment gained a repository contract and implementation; README/CONTEXT now describe the real layering.
- **Database security** — `get_student_dashboard(uuid)` now requires the caller to be that student or a coordinator, pins `search_path`, and is no longer executable by `anon`. See `supabase/README.md` for the migration drift and baseline plan.

## Completed features

- **Auth** — 3-step signup, `@s.unikl.edu.my` validation, email confirmation, specific error messages, stable single-instance router.
- **Journey (home)** — chaptered trail of preparation milestones and the 14 logbook weeks, next-task card, streak copy, celebration overlay with chime/haptics.
- **Enrollment gate** — resolves the student's current semester through `EnrollmentRepository`; shows a pending screen when none exists.
- **Checklist** — batched fetch + batch insert (no N+1), optimistic toggle; its UI is the journey trail.
- **Jobs** — CRUD, statuses, notes, awaited saves with user-visible errors.
- **Documents** — in-app PDF/image preview (`pdfx`), download via system picker, rename, delete, gallery compression, RLS storage key.
- **Logbook** — date-aware states (current / due soon / overdue / upcoming), future weeks locked, confirmation + undo, rollback on failure.
- **Local reminders** — 09:00 the day before each unsubmitted due date; tap opens Logbook (including cold start); rescheduled when the journey or logbook loads.
- **Notifications** — personal messages plus coordinator broadcasts fanned out by DB triggers (with images); unread badge; realtime; swipe/Archive read retain rows via `archived_at`.
- **Chatbot** — rule-based FAQ matching with a short thinking/streaming flow, session drawer and example prompts.
- **Profile / Settings** — name and phone editing; version, celebration sound toggle, sign out, debug-only notification test.

## Identity

- App name: **INTRA Buddy** (Android label + iOS display name), version `1.0.0+1`.
- Launcher icon: blue/teal "B" tile with adaptive layers; splash uses the speech-bubble mark.
- In-app mark: `BrandMark` (`assets/branding/intra_buddy_mark.png`) on auth screens and the chat empty state.
- Bottom dock: 4 tabs, route icons, labels at 10.5px with `FittedBox` scaling for large accessibility text.

## Database

- Migrations in `supabase/migrations/` (10 files). The live project's applied history (17 versions) does **not** match the repo: seven migrations are missing and seven filenames use different timestamps. **Do not run `supabase db push`** until a baseline is adopted — status, commands and the repair plan are in `supabase/README.md`.
- Security applied 2026-11-18: `get_student_dashboard` guard + `search_path` pinning; `anon` grant revoked. The signup trigger uses the already-hardened `private.handle_new_user`.
- Demo data (verified 19 Nov 2026): semester **`INTRA Session 1 2026/2027`** (1 Nov 2026 – 7 Feb 2027, active, registration closed), 14 weeks with weeks 1–2 submitted and week 3 current, demo account `hazieq.azrul@s.unikl.edu.my`, 10 checklist items (4 done), 4 job applications, 2 documents, 6 FAQs, 12 notifications (**0 unread**).
- Backups `_demo_backup_semesters_20261029` / `_demo_backup_weeks_20261029` can be dropped when no longer needed.

## Where things live

- `docs/CONTEXT.md` — architecture, routing, schema, feature deep dives, theme, known issues.
- `supabase/README.md` — database status, baseline procedure, remaining advisories.
- `lib/src/app/` — router, theme, shared shell widgets (`BuddyTopBar`, `BuddyDock`, `BrandMark`).
- `lib/src/core/` — auth service, errors, logger, shared providers.
- `lib/src/features/` — auth, enrollment, dashboard (shell), journey, checklist, jobs, my_documents, logbook, notifications, chatbot, profile, settings.
- Tests mirror `lib/` under `test/src/`.

## Known limits / next steps

1. **No remote push.** Android FCM is deferred; iOS push needs a paid Apple Developer account.
2. **Reminders** reschedule only when the journey/logbook loads.
3. **No unarchive UI** for archived notifications (rows retained for INTRA records).
4. **Providers are not autoDispose**; user-scoped providers reload on auth changes.
5. **Release APK is debug-signed** (sideloading only).
6. **No integration/E2E tests**; the suite is 279 unit/widget tests.
7. **Database baseline pending**; two tables (`coordinator_student_assignments`, `student_management_audit`) have RLS with no policies; leaked-password protection is disabled.
8. **`.env` ships as a Flutter asset** — it must only ever hold the publishable key.

## Demo checklist (when the date is set)

- Mark 2–3 notifications unread so the badge and "archive read" are visible.
- Decide whether signup is part of the script — `registration_open = false` blocks it.
- Uninstall the old app before installing the release APK (launcher icon cache).
- Open the app the morning of the demo (free-tier Supabase pauses on inactivity).
- The "test notification" action is `kDebugMode`-only; it is absent from a release build.

## Conventions

- Logic changes start with tests; verify with `flutter test`, `flutter analyze`, `dart format --set-exit-if-changed .`, and `flutter build apk --release`.
- Conventional commits, one logical change each.
- `docs/CONTEXT.md` is the source of truth; update it with meaningful behaviour changes.
