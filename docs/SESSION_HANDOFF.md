# Session Handoff

Snapshot of the project state so a new session can start without re-reading the whole history.

## Snapshot

| | |
|---|---|
| Repo | `intra_buddy_mobile_v2` (student-facing Flutter app) |
| Branch | `main`, clean and synced with `origin` |
| Last commit | `25229e3 feat(logbook): schedule local reminders before each deadline` |
| Flutter / Dart | 3.47.8 / 3.13.7 |
| Xcode | 27.1 (iOS minimum 15.0, Swift Package Manager) |
| Verification | 145 tests passing, analyzer clean, Android release + iOS simulator builds |

## Completed features

- **Auth** — 3-step signup, `@s.unikl.edu.my` validation, email confirmation, specific error messages, stable single-instance router.
- **Dashboard** — latest-notification banner with empty/loading/error states; INTRA journey (preparation milestones + date-driven 14-week strip); Applications/Documents tiles.
- **Checklist** — batched fetch + batch insert (no N+1), optimistic toggle.
- **Jobs** — CRUD, statuses, notes, awaited saves with user-visible errors.
- **Documents** — correct RLS storage key, in-app PDF/image preview (`pdfx`), download via system picker, rename, delete, gallery compression.
- **Logbook** — date-aware states (current / due soon / overdue / upcoming), future weeks locked, confirmation + undo, rollback on failure.
- **Local reminders** — 09:00 the day before each unsubmitted due date; tap opens Logbook (including cold start); rescheduled when dashboard data loads.
- **Notifications** — personal messages plus coordinator broadcasts fanned out by DB triggers (with images); unread badge; realtime; swipe/Archive read retain rows via `archived_at`; coordinator can read broadcast copies.
- **Chatbot / Profile / Settings** — as before.

## Database

Migrations in `supabase/migrations/` (all applied):

```
20261027090000_notifications_realtime_replica_identity.sql
20261030120000_broadcast_fanout.sql
20261030130000_notifications_delete_policy.sql   (superseded by archive)
20261030140000_notifications_archive.sql
```

Schema additions made along the way: `notifications.image_paths`, `notifications.archived_at`,
`broadcast_messages.image_paths` (teammate), unique `(broadcast_id, recipient_id)`,
fan-out/sync/cleanup triggers, coordinator SELECT policy for broadcast copies.

Demo data: semester **`INTRA Session 1 2026/2027`** (27 Sep 2026 – 31 Jan 2027), 14 weeks,
demo account `hazieq.azrul@s.unikl.edu.my`, demo broadcasts 36/37/38.
Backups: `_demo_backup_semesters_20261029`, `_demo_backup_weeks_20261029`.

## Where things live

- `docs/CONTEXT.md` — architecture, schema, feature deep dives, known issues.
- `lib/src/app/` — router, theme, startup intent, navigation keys.
- `lib/src/features/` — auth, dashboard, checklist, jobs, my_documents, logbook, notifications, chatbot, profile, settings.
- Tests mirror `lib/` under `test/src/`.

## Known limits / next steps

1. **No remote push.** Android FCM is deferred; iOS push is blocked without a paid Apple Developer account.
2. **Session expiry:** `currentUser!` in seven datasources throws and degrades to error screens.
3. **Reminders** reschedule only when app data loads.
4. **Archive** has no unarchive UI (rows retained for INTRA records).
5. **Release APK is debug-signed** (not Play Store ready).
6. FCM plan when picked up: Firebase project → `device_tokens` table → `send-push` Edge Function → DB webhooks.

## Conventions

- Logic changes start with tests; verify with `flutter test`, `dart analyze`, and a release build.
- Conventional commits, one logical change each.
- `docs/CONTEXT.md` is the source of truth; update it with meaningful behaviour changes.
