# INTRA Buddy — Blue Trail Design

**Date:** 2026-10-30
**Status:** Approved direction; design for builder review
**Scope:** The fun, path-led identity for the student app. This document replaces the premium editorial direction for future work. The `design/premium-editorial-ui` branch is kept as a fallback and is not part of this build.

---

## 1. Intent

INTRA Buddy should feel like a companion through the internship, not a status dashboard. The 12-week placement is already a journey; the app should make that journey visible, give the student a clear place to stand each week, and celebrate the small wins that keep them going.

The two ingredients the product owner chose are:

1. **A week-by-week path** — the journey is the spine of the app.
2. **A payoff** — a real, satisfying celebration when something is submitted or completed.

There is no mascot. Personality comes from the path, the streak, the copy, and the feedback.

---

## 2. Who it serves

UniKL students aged roughly 21–25, preparing for or currently on an internship. They open the app:

- before placement, to clear preparation milestones;
- weekly, to submit a logbook;
- occasionally, to check documents and job applications;
- at the end, to finish whatever the coordinator assigns.

The app should feel encouraging and alive without becoming childish or turning deadlines into a game.

---

## 3. Goals

1. A Home screen that shows the current chapter and the one thing to do next.
2. A visible journey from pre-internship milestones through weekly logbooks to wrapping up.
3. A celebration moment with real craft: confetti, a check, a streak increment, haptic feedback.
4. A blue-and-white identity that still feels fun through shape, type, colour and motion.
5. A coordinator-defined journey: milestones are templates, not hard-coded screens.
6. The same system carrying into checklist, logbook, jobs, assistant and the rest.

## 4. Non-goals

- A mascot or character illustration system.
- A coordinator editing UI inside the mobile app. Coordinators use the web dashboard.
- Sound effects.
- A points/XP economy, loot, or leaderboards.
- Changing auth, Supabase business logic, notifications, or the assistant backend.
- Rebuilding the web dashboard.

## 5. Anti-goals

- A game that makes deadlines feel trivial or childish.
- Confetti on every tap; celebration must be earned.
- Fixed counts or fixed milestone titles baked into the UI.
- A path that hides the next action in a long scroll.
- Warm cream/beige, serif type, or the premium editorial look.
- More than one visual accent competing with blue.

## 6. Constraints

- Flutter, Material 3, Riverpod 3, go_router 17.
- Existing architecture (`features/<x>/{data,domain,presentation}`) stays.
- Student rows are generated from `checklist_templates`; the app renders them.
- Weeks come from `weekly_logbook_tracking`; the count is dynamic (commonly 12, sometimes 14).
- The coordinator web dashboard owns template content.
- No schema changes beyond the two additive columns already applied (section 8).
- All existing tests stay green; new logic gets pure-function tests.

---

## 7. The idea: path + payoff

**The path.** Home opens on the chapter the student is in. Above it, completed chapters collapse into a single summary pill. Below it, the next chapter waits. The full journey is one tap away in **Your Journey**.

**The payoff.** Submitting a logbook or completing a milestone triggers a celebration overlay: confetti, a large check, the streak ticking up, and a haptic. Chapter and internship completions get a bigger version.

The journey has three chapters, all driven by data:

| Chapter | Content | Source |
|---|---|---|
| **Getting ready** | Pre-internship milestones | `checklist_templates.phase = 'before'` |
| **The internship** | Weekly logbooks, plus any coordinator milestones during placement | `weekly_logbook_tracking` + `checklist_templates.phase = 'during'` |
| **Wrapping up** | Final report, presentation, exit tasks, or nothing | `checklist_templates.phase = 'after'` |

A chapter with no content is hidden. The app never assumes a fixed number of milestones.

---

## 8. Journey model

### 8.1 Nodes

Two node shapes, so the student can tell them apart at a glance:

- **Week node** — a circle with the week number. States: done, current, upcoming, missed.
- **Milestone node** — a rounded square with a check or a dot. States: done, open, overdue, locked.

Both can be tapped. A week opens the logbook; a milestone opens its checklist detail (or marks it complete, if that is the existing interaction).

### 8.2 Ordering

1. `before` milestones, ordered by `due_date` (nulls last), then `display_order`.
2. Weeks `1..totalWeeks`, ordered by week number.
3. `during` milestones merged with weeks by due date. A milestone due in week 6 appears after week 6 and before week 7. A during milestone with no due date is appended at the end of the during chapter, by `display_order`.
4. `after` milestones, ordered by `due_date` (nulls last), then `display_order`.
5. If there are no `after` milestones, the trail ends with a completion node: "Journey complete".

### 8.3 Status

- **Week:** submitted before its `week_end_date` → done; submitted after → done but not counted toward the streak; current week not submitted → current; past and not submitted → missed; future → upcoming.
- **Milestone:** `is_completed` → done; incomplete with a due date in the past → overdue; otherwise open.
- **Locked:** a future node that cannot be acted on yet (for example, an `after` milestone before the internship ends) uses the dashed pale-blue style. Locked is presentation only; do not block a real submission if the data allows it.

### 8.4 Current position and next action

- The **position marker** is the current week. Home auto-scrolls to it on first open.
- The **next action** is the most urgent incomplete node:
  1. incomplete milestones that are overdue or due within seven days, earliest first;
  2. the current week's logbook, if unsubmitted;
  3. the first incomplete node in journey order.
- The current node card always shows the next action, even if it belongs to an earlier chapter. If the student has scrolled away, a "Jump to now" chip appears.
- **Anchors:** before placement starts, anchor to Getting ready; during placement, anchor to the current week; after the final week, anchor to Wrapping up. With no weeks at all, anchor to Getting ready; with no nodes at all, show the empty state.

### 8.5 Streak

- Count consecutive weeks ending at the most recent week whose `week_end_date` has passed.
- A week counts only if submitted on time: `submitted_at <= week_end_date` end of day. If `submitted_at` is null but `is_submitted` is true, treat it as on time for legacy rows.
- A missed week resets the streak.
- The current week does not break the streak while it is still in progress.
- Copy: `6-week streak`; zero → `Start a streak`.
- The streak is derived, never stored.

### 8.6 Progress

- Chapter progress: completed nodes / total nodes in that chapter.
- Journey progress: completed nodes / total nodes across all chapters.
- Home shows the chapter progress; Your Journey shows the whole-journey progress.

---

## 9. Data contract

### 9.1 Applied migration

`add_checklist_template_phase_due_date` (already applied):

- `checklist_templates.phase text null` with a check constraint: `before`, `during`, `after`.
- `checklist_templates.due_date date null`.
- Both are readable with the table; no RLS changes.

### 9.2 Coordinator responsibilities (web dashboard)

The partner's dashboard should:

- Set `phase` on every checklist template.
- Set `due_date` when the milestone has a real deadline.
- Keep `display_order` as the tie-breaker.
- Use `during` for mid-term reports, supervisor visits, presentations, etc.
- Use `after` for final report, final presentation, exit form, and anything post-placement.

### 9.3 Student app responsibilities

- Join `checklist_templates` for `title`, `phase`, `due_date` (the student row already has `due_date`).
- When generating missing student rows, copy the template's `due_date` into the student row. Existing student rows keep their own due date.
- If `phase` is null:
  - `due_date < semester start` → `before`
  - `due_date > semester end` → `after`
  - otherwise → `during`
  - if `due_date` is also null → `before` (the current four templates are pre-internship).
- Never hard-code a milestone title, week count, or chapter count.
- Render whatever `weekly_logbook_tracking` rows exist. The legacy 14-row seed is not changed in this build; the coordinator/web dashboard should own week generation. If no rows exist, the unique Home empty state explains that the logbook is not set up yet.
- If a chapter is empty, hide it. If all chapters are empty, show a single empty state pointing to the checklist.

### 9.4 No other data changes

No writes beyond the existing checklist toggle and logbook submission. No new tables.

---

## 10. Visual system

### 10.1 Palette

| Token | Hex | Use |
|---|---|---|
| `blue` | `#2563EB` | Primary progress, buttons, active dock |
| `blueDeep` | `#1D4ED8` | Pressed/3D button edge |
| `sky` | `#60A5FA` | Secondary progress, week line, confetti |
| `ice` | `#E7F0FF` | Chapter washes, current-week halo |
| `page` | `#F4F8FF` | Page background |
| `white` | `#FFFFFF` | Cards, nodes, sheets |
| `navy` | `#0F2A4A` | Primary text |
| `muted` | `#5C6F86` | Secondary text |
| `line` | `#DCE8FF` | Hairlines, future path |
| `lineStrong` | `#C9D9F5` | Dashed locked borders |
| `sun` | `#FFC53D` | Current node, streak, celebration only |
| `sunDeep` | `#D99A16` | Sun 3D edge |
| `sunText` | `#5C4300` | Text on sun |
| `flame` | `#FFB020` | Streak flame |
| `alert` | `#E5484D` | Missed/overdue only |

Rules:

- Blue is the only action colour.
- Yellow is not a button colour except the celebration's primary action; on normal screens it is reserved for the current node and streak.
- Green is not used. Completion is blue and a check.
- Never pure black. No gradients except a subtle sky→blue progress bar, the confetti, and the page wash.

### 10.2 Type

- **Fredoka** 400/500/600 for headlines, numbers, buttons.
- **Nunito** 400/600/700/800 for body, labels, metadata.
- Scale: display 34, H1 29, H2 22, H3 18, body 13–14, caption 11, overline 8–9 (800, tracking 0.14–0.18em).
- Buttons: Fredoka 600 or Nunito 800.
- No serif anywhere.

### 10.3 Shape and depth

- Cards 18–20px radius; buttons 11–14px; nodes 38–64px circles; milestone squares 13–34px with 4–11px radius.
- Cards: white, 1.5px `rgba(15,42,74,0.07)` border, soft shadow `0 5px 0 rgba(15,42,74,0.05)`.
- Buttons: 3D bottom edge (`0 4px 0 blueDeep` for primary, `0 5px 0 sunDeep` for the celebration).
- Dashed borders for locked/empty.
- No glass, blur, or heavy gradients.

### 10.4 Icons

- Material rounded icons (`Icons.*_rounded`) at 18–20px, 2px stroke feel.
- One icon per action; no icon stacks.
- Week nodes use numbers; milestone nodes use a check or a dot.

### 10.5 Motion

- Node pop: 240ms, scale 0.9 → 1.04 → 1, ease-out.
- Path draw on first load: 400ms, top to current.
- Card enter: 220ms fade + 8px rise.
- Celebration: 900ms confetti + check pop; light/medium haptic.
- Streak flame bounce: 600ms when incremented.
- Page transitions: 220ms fade-through, no full-screen slide.
- Reduced motion: no confetti, no pops, no path draw; state changes instantly.
- Haptics: light impact on tab/dock, medium on weekly celebration, heavy on chapter/internship completion.

### 10.6 Celebration

- Full-screen overlay on `blue`, with a white check circle, a sun burst, confetti in blue/sky/sun/white, the headline ("Week 7 done!"), the streak, a progress card, and one primary action.
- Weekly celebration: medium haptic, 900ms confetti.
- Chapter completion: larger burst, headline names the chapter.
- Internship completion: biggest burst, "You did it." plus a summary.
- Dismiss: tap outside or "Keep going"; do not auto-dismiss.
- The celebration follows the app's status update, not the INTRA portal submission. The copy says "marked submitted" where it would otherwise imply the portal. Undo never celebrates; re-marking after an undo may celebrate again because it is a successful transition.

---

## 11. Components

| Component | Responsibility |
|---|---|
| `BuddyScaffold` | Ice page, safe areas, scroll, pull-to-refresh |
| `BuddyTopBar` | Brand, streak pill, profile avatar |
| `ChapterPill` | Collapsed chapter summary with count, tap to open |
| `TrailChapter` | Chapter header + nodes + connector line |
| `TrailNode` | Week or milestone node with status and tap |
| `WeekTrack` | Horizontal 1..N week map for Your Journey |
| `CurrentTaskCard` | The next action, with primary CTA |
| `StreakBadge` | Flame + count + dot row |
| `PrimaryButton` | Blue 3D button |
| `SunButton` | Celebration-only sun 3D button |
| `CelebrationOverlay` | Confetti, check, streak, progress, action |
| `MilestoneRow` | Checklist row with rounded-square state |
| `EmptyState` | Copy + one action |

Build these before screens. No screen invents its own card or button.

---

## 12. Screens

### 12.1 Home — Now

- Top bar: brand, streak pill, avatar.
- Hero: `WEEK 7 OF 12`, "Halfway there!", "5 weeks to go".
- Trail:
  - collapsed `GETTING READY · 4/4` pill;
  - completed week/milestone nodes;
  - current week node (sun) with the current card;
  - next week;
  - `WRAPPING UP` teaser with coordinator count or "nothing assigned yet".
- Streak card.
- Dock.
- Auto-scroll to the current week; "Jump to now" if scrolled away.

### 12.2 Your Journey

- Pushed screen, back arrow.
- Hero: "The whole story." + counts.
- Three chapter blocks connected by a rail:
  - Getting ready: milestone rows with checks.
  - The internship: 1..N week track, current week sun, during milestones.
  - Wrapping up: coordinator milestones or an empty note.
- Journey progress bar.
- Tapping a node opens the week or milestone.
- Empty chapters hidden.

### 12.3 Celebration

- Overlay described in 10.6.
- Triggered after a successful logbook submission or milestone completion.
- The background screen stays visible dimmed under the overlay.

### 12.4 Later phases

The same system restyles Checklist, Logbook, Jobs, INTRA Assistant, Documents, Notifications, Profile, Settings and Auth. Those screens keep their existing flows and data; only presentation changes. They are separate plans after the trail proves the system.

---

## 13. Interaction and states

- **Loading:** skeleton chapter blocks, no spinner.
- **Empty chapter:** hidden; if all empty, one empty state.
- **Empty trail:** "Your journey starts here." + "Ask your coordinator to add the first milestone." + "Open checklist".
- **Error:** "Couldn't load your journey." + "Try again".
- **Pull-to-refresh** on Home and Your Journey.
- **Tap target:** 48×48 minimum; node taps include the label area.
- **Semantics:** each node reads "Week 7, current, logbook due Friday" or "Supervisor confirmation, done".
- **No dead ends:** every locked node explains who assigns it.

---

## 14. Accessibility

- Blue on white/ice ≥ 4.5:1; white on blue ≥ 4.5:1; sun text on sun ≥ 4.5:1; muted on ice ≥ 4.5:1.
- Status is always a word before a colour ("Done", "Current", "Missed", "Locked").
- Text scale 2.0: cards grow; nodes keep their circle but labels wrap; the trail remains scrollable; no clipped cards.
- Reduced motion honoured.
- Confetti is decorative, excluded from semantics.
- Haptics are additive, never the only signal.

---

## 15. Performance

- Build the trail as a lazy list (slivers), not a Column of every node.
- One confetti painter, no per-particle widgets; dispose after the animation.
- No backdrop blur.
- Auto-scroll once; do not fight the student's scroll.
- Cache the derived journey per provider rebuild; pure functions for ordering, next action, streak and progress.
- Target 60fps on a mid-range Android phone.

---

## 16. Technical approach

- New `lib/src/app/theme/tokens.dart` with the palette, radii, shadows, durations.
- `AppTheme` light only for the first phase; dark mode is a later phase (role-swap to navy surfaces).
- Bundle Fredoka and Nunito (OFL).
- `features/journey/domain/journey.dart`:
  - `JourneyNode` (week or milestone), `JourneyChapter`, `Journey`.
  - `buildJourney({checklistItems, weeks, semesterStart, semesterEnd, now})`.
  - `nextAction`, `streak`, `chapterProgress`, `journeyProgress`.
  - Pure functions, fully tested.
- `features/journey/presentation/` for the trail widgets and Home/Your Journey.
- Keep `dashboardProvider` but replace its payload with the journey model, or introduce `journeyProvider`. Prefer a new provider so the old dashboard can be removed cleanly.
- Data:
  - Extend `ChecklistItem` with `phase` and `dueDate` (phase joined from the template, due date from the student row).
  - Copy `due_date` on insert.
  - Add `semesters.name` to the semester select.
- Shell: blue dock with labels, 4 tabs, profile avatar. Reuse the dock fix (shrink-wrap) and the 48px targets.
- Remove the premium tokens/components from this branch; they are not merged here.

---

## 17. Rollout

**Phase 0** — branch `design/blue-trail` from `main`.

**Phase 1 — Foundations + journey model**
Tokens, fonts, theme, base components, `JourneyNode/Chapter/Journey`, ordering, next action, streak, progress, tests.

**Phase 2 — Home**
Trail, chapter pills, current card, streak, dock, auto-scroll, celebration trigger.

**Phase 3 — Your Journey + Celebration**
Full chapter map, week track, celebration overlay, chapter/internship variants.

**Phase 4 — Checklist + Logbook** re-skinned on the same system.

**Phase 5 — Jobs + Assistant.**

**Phase 6 — Documents, Notifications, Profile, Settings.**

**Phase 7 — Auth + dark mode + polish.**

Each phase ships independently.

---

## 18. Testing

- Pure-function tests: ordering, phase inference, next action, streak (on-time, late, missed, in-progress), progress, empty chapters, zero weeks.
- Widget tests: `TrailNode` states, `ChapterPill`, `WeekTrack`, `CurrentTaskCard`, `CelebrationOverlay` (reduced motion), 2× text.
- Existing tests stay green.
- Manual: 375×667, 430×932, text scale 2.0, dark mode later, reduced motion, one real device.

---

## 19. Risks

| Risk | Mitigation |
|---|---|
| Coordinator forgets `phase` | App infers from due date; web dashboard should require it |
| Weeks vary (12/14) | Never hard-code; use `totalWeeks` |
| Trail gets long | Lazy slivers, auto-scroll to current, collapse past chapters |
| Celebration feels childish | Earned moments only; copy stays adult; no points/leaderboards |
| Confetti jank | One painter, 900ms cap, reduced-motion off switch |
| Streak wrong for late submissions | Compare `submitted_at` to `week_end_date`; test late/missed cases |
| Auto-scroll fights the user | Once on first load; "Jump to now" afterwards |
| Legacy 14-week seed conflicts with 12-week placements | UI never hard-codes; render existing rows; revisit generation with the web dashboard |
| Partner contract drift | Section 9 is the contract; columns nullable and additive |
| Blue/yellow contrast | Token tests for the key pairs |

---

## 20. Calls made

- No mascot.
- Three chapters, all data-driven; empty chapters hidden.
- Blue/white with sun reserved for current/streak/celebration.
- Fredoka + Nunito; no serif.
- 3D buttons; no glass/gradients.
- Home = Now; Your Journey = full arc.
- Weekly and chapter celebrations, no points/XP.
- Coordinator web dashboard owns templates; mobile is a renderer.
- `phase`/`due_date` columns applied as nullable; fallback inference.
- Premium editorial branch untouched.
- Home anchors to Getting ready before placement, the current week during it, and Wrapping up after the final week.
- Celebration follows the app's status update, not the portal; copy says "marked submitted".
- The legacy 14-row week seed stays for now; the UI renders whatever rows exist.

## 21. Left to the builder

- Exact file splits under `features/journey/`.
- Confetti implementation (CustomPainter recommended).
- Whether to keep the old `dashboardProvider` as a thin adapter or replace it.
- The precise "lock" rule for future after-milestones.
- Dark-mode palette mapping in Phase 7.
