# INTRA Buddy Mobile — Design Spec

> **Project:** Student-facing mobile app for UniKL internship management
> **Version:** 0.1.0
> **Platform:** Flutter (iOS, Android)

## Architecture

**Pattern:** Feature-first Clean Architecture with 3 layers per feature:
- `domain/` — entities, repository interfaces, use cases
- `data/` — models (JSON serialization), data sources, repository implementations
- `presentation/` — Riverpod providers, screens, widgets

**State management:** Riverpod with code generation (`@riverpod` + `.g.dart`)
**Routing:** GoRouter with `StatefulShellRoute.indexedStack` for bottom nav persistence
**Dependency injection:** Constructor injection via Riverpod providers

## Design System

**Theme:** Light-first Material 3 with custom tokens.

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

**Typography:** Inter (Google Fonts)

| Style | Size/Height | Weight |
|-------|-------------|--------|
| Display Large | 32/40 | Bold |
| Headline Large | 28/36 | SemiBold |
| Title Large | 20/28 | SemiBold |
| Title Medium | 16/24 | Medium |
| Body Large | 16/24 | Regular |
| Body Medium | 14/20 | Regular |
| Label Large | 14/20 | Medium |
| Label Small | 12/16 | Medium |

## Navigation

```
Auth check (GoRouter redirect)
  ├─ Not logged in → /login or /signup
  └─ Logged in → / (StatefulShellRoute)
       ├─ /dashboard       (tab 0 — Dashboard)
       ├─ /checklist       (tab 1 — Checklist)
       ├─ /jobs            (tab 2 — Job Applications)
       ├─ /chat            (tab 3 — Chatbot)
       └─ /my-documents    (tab 4 — My Documents)
  ├─ /notifications (pushed from bell icon)
  ├─ /logbook       (pushed from More menu)
  ├─ /profile       (pushed from More menu)
  └─ /settings      (pushed from More menu)
```

## Feature List

| Feature | Description |
|---------|-------------|
| Auth | Email/password login and signup with student validation |
| Dashboard | Greeting, milestone progress, job stats, logbook, document count |
| Checklist | Milestone checklist with toggle, lazy row creation |
| Jobs | Company/position/status tracker with CRUD |
| My Documents | Document upload/view/delete via Supabase Storage |
| Logbook | Weekly week-number submit toggle |
| Notifications | Grouped inbox with mark-read and swipe-delete |
| Chatbot | Rule-based FAQ matching with session history |
| Profile | View/edit name, student ID, phone, avatar |
| Settings | Logout, preferences |

## Data Flow

```
Screen (ConsumerWidget)
  └─ watches Provider (AsyncNotifier or family)
       └─ calls UseCase
            └─ calls Repository (interface)
                 └─ calls DataSource
                      └─ calls Supabase.instance.client or Storage
```

## Known Decisions

- No OAuth or magic link — email/password only
- No external LLM API — rule-based FAQ matching
- Student email: `@s.unikl.edu.my` only
- Upload limit: 5 MB per document
- Storage bucket: `student-documents` with signed URLs (60s)
