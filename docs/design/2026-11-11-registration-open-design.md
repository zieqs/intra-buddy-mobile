# Registration-open semester design

**Date:** 2026-11-11
**Status:** Implemented

## Intent

Students should never pick their INTRA semester. They are assigned by the
coordinator. But the assignment must still work when the next cohort signs up
before the current session ends, which is exactly when a coordinator briefs
that cohort and introduces the app.

## The problem with `is_active`

`is_active` means "the session currently running". Using it to choose a new
student's semester breaks at the boundary between sessions: Session 2 students
signing up in January would be enrolled in Session 1 and see its checklist,
journey phase, and logbook weeks.

Session membership is an administrative fact. Only the coordinator knows which
intake a student belongs to, so the app must not infer it from timing.

## Decision

Add a second flag, `semesters.registration_open`:

- `is_active` — the session currently running (announcements, dates, etc.)
- `registration_open` — the session new signups join

At most one semester may be open (partial unique index).

Flow:

1. The coordinator creates the next session and turns "Open for registration"
   on before the briefing.
2. The signup screen shows that session (name and dates) read through the
   pre-auth `get_open_semester` RPC.
3. The `handle_new_user` trigger enrolls the student in the open session.
4. If nothing is open, signup is blocked with a "contact your coordinator"
   message.
5. Existing students are unaffected: resolution is scoped to their own
   `student_semesters` rows, not the active/open flags.

A post-login enrollment gate covers orphan accounts (signed up while nothing
was open, or the coordinator changed their enrollment): it shows a pending
screen with refresh, contact, and sign-out actions instead of empty screens.

## Alternatives considered

- **Student picks from open sessions** — rejected: students do not know the
  internal session names, and a wrong choice corrupts checklist and logbook
  data.
- **Join code per semester** — deferred: precise and works with concurrent
  intakes, but adds a field and friction. Move to it only if late signups from
  the previous cohort or concurrent briefings become common.
- **Admin assigns after signup** — kept as the fallback for late/edge cases,
  not the primary flow, because it delays access.

## Known trade-offs

- A late Session 1 student signing up during Session 2's window joins Session
  2 and needs a manual fix from the dashboard.
- The coordinator must open registration before the briefing. If they forget,
  signup is blocked (deliberately) with a clear message.
- Opening the next session requires closing the current one first.

## Operational note

Applied to the shared project on 2026-11-11 as migration `20261111053829`.
`INTRA Session 1 2026/2027` (id 1) is open for registration. Before the next
intake's briefing, close it and open the next session.

The dashboard can flip the flag with two updates (coordinators already have
update access to `semesters`):

```sql
update public.semesters set registration_open = false where registration_open;
update public.semesters set registration_open = true  where id = <session id>;
```

## Implementation

- `supabase/migrations/20261111053829_registration_open.sql` — column, partial
  unique index, updated `handle_new_user`, `get_open_semester` RPC.
- `lib/src/features/enrollment/` — `Enrollment`, `pickCurrentEnrollment`,
  Supabase datasource, providers, enrollment gate, pending screen, semester
  card, date formatting.
- Shared resolution replaces the duplicated lookups in the journey, checklist,
  and logbook datasources. Logbook rows are now scoped by semester as well.
- Signup and Settings show the session read-only; the signup `NEXT` button is
  disabled when no session is open.
