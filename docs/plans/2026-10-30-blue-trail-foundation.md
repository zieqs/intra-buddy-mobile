# INTRA Buddy Blue Trail — Foundation, Home & Celebration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the stock dashboard with the blue chaptered trail: a data-driven journey from coordinator milestones through weekly logbooks to wrapping up, with a weekly celebration.

**Architecture:** Add a pure journey domain (nodes, chapters, ordering, next action, streak), then compose Home and Your Journey from a small component layer. The coordinator's web dashboard owns checklist templates; the app renders them. No schema changes beyond the two columns already applied.

**Tech Stack:** Flutter, Material 3, Riverpod 3, go_router 17, bundled Fredoka + Nunito, `flutter_test`.

**Spec:** `docs/design/2026-10-30-blue-trail-design.md`

**Scope:** Phases 1–3 of the spec: foundations, journey model, Home, Your Journey, celebration, and the blue shell. Checklist, logbook, jobs, assistant, documents, profile, auth and dark mode get separate plans.

---

## Global Constraints

- Palette: page `#F4F8FF`, white `#FFFFFF`, ice `#E7F0FF`, blue `#2563EB`, blueDeep `#1D4ED8`, sky `#60A5FA`, navy `#0F2A4A`, muted `#5C6F86`, line `#DCE8FF`, lineStrong `#C9D9F5`, sun `#FFC53D`, sunDeep `#D99A16`, sunText `#5C4300`, flame `#FFB020`, alert `#E5484D`.
- Fredoka for display/headings/buttons; Nunito for body/labels. No serif.
- Cards 18–20px radius; buttons 11–14px; 3D bottom edge; no glass/gradients.
- Blue is the only action colour. Sun only on the current node, streak, and celebration.
- Every tap target ≥48×48. Status is a word before a colour.
- No hard-coded milestone titles, week count, or chapter count.
- Coordinator templates: `phase` ∈ before/during/after, optional `due_date` (already applied to Supabase).
- Home anchors: before placement → Getting ready; during → current week; after final week → Wrapping up; no nodes → empty state.
- Celebration follows a successful "mark submitted" transition, not the portal submission. Undo never celebrates.
- Render whatever `weekly_logbook_tracking` rows exist; the legacy 14-row seed is not changed in this plan.
- Light theme only in this phase (`themeMode: ThemeMode.light`); dark mode is Phase 7.
- `flutter analyze` clean and all tests pass at the end of every task.

## Review Focus

1. **Text scale 2.0 on 375×667** — trail cards, chapter pills and the current card grow/wrap without clipping (Tasks 6 and 7).
2. **No semester, no weeks, or no milestones** — Home anchors correctly, no division by zero, no invented nodes (Tasks 3 and 7).
3. **Phase inference with nulls** — explicit phase wins; null due date falls back to `before`; no milestone disappears (Task 3).
4. **Streak edge cases** — late, missed, in-progress, and `submitted_at` null (Task 4).
5. **Reduced motion and celebration** — no confetti/pops, but the result is still shown (Task 9).

---

## Task 1: Blue tokens, bundled fonts, and theme

**Files:**
- Modify: `lib/src/app/theme/app_colors.dart`
- Create: `lib/src/app/theme/tokens.dart`
- Create: `assets/fonts/Fredoka-400.ttf`, `-500.ttf`, `-600.ttf`
- Create: `assets/fonts/Nunito-400.ttf`, `-600.ttf`, `-700.ttf`, `-800.ttf`
- Create: `assets/fonts/licenses/OFL-Fredoka.txt`, `OFL-Nunito.txt`
- Modify: `pubspec.yaml`
- Modify: `lib/src/app/theme/app_typography.dart`
- Modify: `lib/src/app/theme/app_theme.dart`
- Modify: `lib/src/app/intra_buddy_app.dart` (force light)
- Test: `test/src/app/theme/tokens_test.dart`
- Test: `test/src/app/theme/app_typography_test.dart`
- Test: `test/src/app/theme/app_theme_test.dart`

**Interfaces:**
- Produces: `AppColors` blue palette + `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`.
- Produces: `ThemeColor` getters `page`, `card`, `ice`, `blue`, `blueDeep`, `sky`, `ink`, `muted`, `line`, `lineStrong`, `sun`, `sunText`, `alert`.
- Keeps: legacy `AppColors.primary` etc. as aliases so untouched screens compile.

- [ ] **Step 1: Generate the static fonts**

```bash
pip3 install --user fonttools
mkdir -p assets/fonts/licenses
TMP=$(mktemp -d)
curl -L -o "$TMP/Fredoka.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/fredoka/Fredoka%5Bwdth,wght%5D.ttf"
curl -L -o "$TMP/Nunito.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/Nunito%5Bwght%5D.ttf"
for w in 400 500 600; do
  python3 -m fontTools.varLib.instancer "$TMP/Fredoka.ttf" wght=$w wdth=100 \
    -o "assets/fonts/Fredoka-$w.ttf"
done
for w in 400 600 700 800; do
  python3 -m fontTools.varLib.instancer "$TMP/Nunito.ttf" wght=$w \
    -o "assets/fonts/Nunito-$w.ttf"
done
rm -rf "$TMP"
curl -L -o assets/fonts/licenses/OFL-Fredoka.txt \
  https://raw.githubusercontent.com/google/fonts/main/ofl/fredoka/OFL.txt
curl -L -o assets/fonts/licenses/OFL-Nunito.txt \
  https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/OFL.txt
```

Expected: 3 Fredoka and 4 Nunito static TTFs, plus two licences.

- [ ] **Step 2: Declare the fonts and remove the runtime fetch**

Add under `flutter:` in `pubspec.yaml`:

```yaml
  fonts:
    - family: Fredoka
      fonts:
        - asset: assets/fonts/Fredoka-400.ttf
        - asset: assets/fonts/Fredoka-500.ttf
          weight: 500
        - asset: assets/fonts/Fredoka-600.ttf
          weight: 600
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-400.ttf
        - asset: assets/fonts/Nunito-600.ttf
          weight: 600
        - asset: assets/fonts/Nunito-700.ttf
          weight: 700
        - asset: assets/fonts/Nunito-800.ttf
          weight: 800
```

Remove `google_fonts` from `dependencies`; run `flutter pub get`.

- [ ] **Step 3: Write the failing tests**

`tokens_test.dart`:

```dart
test('blue palette', () {
  expect(AppColors.page.toARGB32(), 0xFFF4F8FF);
  expect(AppColors.blue.toARGB32(), 0xFF2563EB);
  expect(AppColors.sun.toARGB32(), 0xFFFFC53D);
  expect(AppColors.alert.toARGB32(), 0xFFE5484D);
});
test('key pairs meet 4.5:1', () {
  expect(_contrast(AppColors.white, AppColors.blue), greaterThanOrEqualTo(4.5));
  expect(_contrast(AppColors.ink, AppColors.page), greaterThanOrEqualTo(4.5));
  expect(_contrast(AppColors.muted, AppColors.page), greaterThanOrEqualTo(4.5));
  expect(_contrast(AppColors.sunText, AppColors.sun), greaterThanOrEqualTo(4.5));
});
testWidgets('semantic colours resolve', ...);
```

`app_typography_test.dart`:

```dart
expect(t.headlineLarge?.fontFamily, 'Fredoka');
expect(t.titleLarge?.fontFamily, 'Fredoka');
expect(t.bodyMedium?.fontFamily, 'Nunito');
expect(t.labelLarge?.fontFamily, 'Nunito');
expect(t.bodyMedium!.fontSize, greaterThanOrEqualTo(13));
```

`app_theme_test.dart`:

```dart
expect(AppTheme.light.scaffoldBackgroundColor, AppColors.page);
expect(AppTheme.light.colorScheme.primary, AppColors.blue);
expect(AppTheme.light.cardTheme.color, AppColors.white);
expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'Nunito');
```

- [ ] **Step 4: Run the tests to verify they fail**

Run: `flutter test test/src/app/theme -r compact`
Expected: FAIL — missing palette/fonts/getters.

- [ ] **Step 5: Implement the palette, type and theme**

Palette values from Global Constraints. Additional: `white`, `ink`, `muted`, `line`, `lineStrong`, `sunDeep`, `sunText`, `flame`, `alert`, `alertWash` (`0x1AE5484D`), `ice`, `blueWash` (`0x1A2563EB`), `sunWash` (`0x1AFFC53D`).

Legacy aliases: `primary = blue`, `secondary = sky`, `tertiary = sun`, `error = alert`, `lightBackground = page`, `lightSurface = white`, `lightOnSurface = ink`, `lightOutline = line`, `lightMuted = muted`, `lightPrimaryContainer = blueWash`, `lightOnPrimaryContainer = blue`, `lightTertiaryContainer = sunWash`, `lightOnTertiaryContainer = sunText`, plus the matching dark aliases mapped to navy surfaces. Do not add `@Deprecated` (22 untouched files would fail analyze).

`AppTypography`:

```dart
final base = Typography.material2021().black.apply(fontFamily: 'Nunito');
displayLarge 34/1.0 Fredoka 600
headlineLarge 29/1.02 Fredoka 600
headlineMedium 22/1.1 Fredoka 600
titleLarge 18/1.2 Fredoka 600
titleMedium 14/1.4 Nunito 700
titleSmall 13/1.4 Nunito 700
bodyLarge 14/1.5 Nunito 400
bodyMedium 13/1.55 Nunito 400
bodySmall 11/1.4 Nunito 600
labelLarge 9/1.2 Nunito 800 letterSpacing 1.4
labelSmall 8/1.2 Nunito 800 letterSpacing 1.2
```

`AppTheme.light`: `scaffoldBackgroundColor: page`; `ColorScheme.light(primary: blue, onPrimary: white, secondary: sky, surface: page, onSurface: ink, outline: line, error: alert, ...)`; cards white with 1.5px line border and `0 5px 0 rgba(15,42,74,0.05)`; inputs white with line border and 2px blue focus; buttons blue 3D via `PrimaryButton` (keep Material defaults for untouched screens); bottom sheets white, top radius 24; snackbar navy.

Set `themeMode: ThemeMode.light` in `IntraBuddyApp` for this phase. Keep `AppTheme.dark` compiling (navy mapping); it is not used yet.

Create `tokens.dart`:

```dart
AppSpacing: xs 4, sm 8, md 12, lg 16, xl 20, xxl 24, xxxl 32
AppRadii: card 20, node 999, button 14, sheet 24
AppShadows.card: [BoxShadow(color: Color(0x0D0F2A4A), blurRadius: 0, offset: Offset(0, 5))]
AppDurations: quick 160ms, standard 220ms, celebration 900ms
```

- [ ] **Step 6: Run tests and analyse**

Run: `flutter test test/src/app/theme -r compact`
Expected: PASS.

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 7: Commit**

```bash
git add assets/fonts pubspec.yaml pubspec.lock lib/src/app/theme lib/src/app/intra_buddy_app.dart test/src/app/theme
git commit -m "feat(theme): add the blue trail palette, fonts and theme"
```

---

## Task 2: Carry checklist phase and due dates through the read path

**Files:**
- Modify: `lib/src/features/checklist/domain/entities/checklist_item.dart`
- Modify: `lib/src/features/checklist/data/models/checklist_item_model.dart`
- Modify: `lib/src/features/checklist/data/models/checklist_item_model.g.dart` (build_runner)
- Modify: `lib/src/features/checklist/data/datasources/checklist_merger.dart`
- Modify: `lib/src/features/checklist/data/datasources/checklist_remote_datasource.dart`
- Modify: `lib/src/features/checklist/presentation/providers/checklist_controller.dart`
- Modify: `lib/src/features/logbook/data/datasources/logbook_remote_datasource.dart`
- Modify: `lib/src/features/logbook/data/repositories/logbook_repository_impl.dart`
- Modify: `lib/src/features/logbook/domain/repositories/logbook_repository.dart`
- Test: `test/src/features/checklist/data/datasources/checklist_merger_test.dart`
- Test: `test/src/features/checklist/data/models/checklist_item_model_test.dart`

**Interfaces:**
- Produces: `ChecklistItem.phase` (`String?`) and `ChecklistItem.dueDate` (`DateTime?`).
- Produces: `LogbookRepository.loadExistingWeeks()` — read-only, does not seed.

- [ ] **Step 1: Write the failing tests**

Add to the merger test:

```dart
test('carries phase and due date from the template and student row', () {
  final rows = mergeChecklistRows(
    templates: [
      {..._template(1), 'phase': 'before', 'due_date': '2026-09-30'},
    ],
    existing: [
      {..._row(101, 1), 'due_date': '2026-10-02'},
    ],
    inserted: const [],
  );
  expect(rows.single['phase'], 'before');
  expect(rows.single['due_date'], '2026-10-02');
});
```

Create the model test:

```dart
test('maps phase and due_date', () {
  final model = ChecklistItemModel.fromJson({...all fields, 'phase': 'after', 'due_date': '2027-01-20'});
  expect(model.phase, 'after');
  expect(model.dueDate, DateTime(2027, 1, 20));
  expect(model.toEntity().phase, 'after');
});
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/src/features/checklist/data -r compact`
Expected: FAIL.

- [ ] **Step 3: Add the fields and regenerate**

- `ChecklistItem`: add `final String? phase; final DateTime? dueDate;` with optional constructor args.
- `ChecklistItemModel`: add `final String? phase;` (plain) and `@JsonKey(name: 'due_date') final DateTime? dueDate;`, map both in `toEntity()`.
- Run `dart run build_runner build --delete-conflicting-outputs`.
- `mergeChecklistRows`: emit `'phase': template['phase']` and `'due_date': row['due_date']`. The student row's due date wins; the template date is copied at insert.
- `ChecklistRemoteDataSource` insert: add `'due_date': template['due_date']` so new rows get the coordinator's date.
- `ChecklistController.toggleItem`: copy `phase` and `dueDate` into the replacement item.
- `LogbookRemoteDataSource`: add

```dart
Future<List<Map<String, dynamic>>> loadExistingWeeks() async {
  return supabase.from('weekly_logbook_tracking').select()
      .eq('student_id', _userId).order('week_number', ascending: true);
}
```

- `LogbookRepository` + impl: add `loadExistingWeeks()` using that method.
- Keep `loadWeeks()`'s seed unchanged.

- [ ] **Step 4: Run tests and analyse**

Run: `flutter test test/src/features/checklist/data -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/checklist lib/src/features/logbook test/src/features/checklist
git commit -m "feat(checklist): carry phase and due dates into the journey data"
```

---

## Task 3: Journey model, phase inference and ordering

**Files:**
- Create: `lib/src/features/journey/domain/journey.dart`
- Create: `lib/src/features/journey/domain/build_journey.dart`
- Test: `test/src/features/journey/domain/journey_phase_test.dart`
- Test: `test/src/features/journey/domain/journey_order_test.dart`

**Interfaces:**
- Produces: `JourneyNodeKind { week, milestone }`, `JourneyNodeState { done, current, open, missed, locked }`, `JourneyChapterKind { before, during, after }`.
- Produces: `JourneyNode`, `JourneyChapter`, `Journey` (including `Journey.empty()`, `chapterFor(kind)`, `anchorKind`, `progress`, `isEmpty`).
- Produces: `JourneyChapterKind phaseFor(ChecklistItem item, DateTime? semesterStart, DateTime? semesterEnd)`.
- Produces: `Journey buildJourney({required List<ChecklistItem> checklist, required List<LogbookWeek> weeks, required DateTime? semesterStart, required DateTime? semesterEnd, String? semesterName, required DateTime now})`.

- [ ] **Step 1: Write the failing phase tests**

```dart
test('explicit phase wins', () {
  expect(phaseFor(_item(phase: 'after'), DateTime(2026, 9, 27), DateTime(2027, 1, 31)), JourneyChapterKind.after);
});
test('infers before and after from the semester dates', () {
  expect(phaseFor(_item(due: DateTime(2026, 9, 20)), DateTime(2026, 9, 27), DateTime(2027, 1, 31)), JourneyChapterKind.before);
  expect(phaseFor(_item(due: DateTime(2027, 2, 2)), DateTime(2026, 9, 27), DateTime(2027, 1, 31)), JourneyChapterKind.after);
  expect(phaseFor(_item(due: DateTime(2026, 11, 6)), DateTime(2026, 9, 27), DateTime(2027, 1, 31)), JourneyChapterKind.during);
});
test('no phase and no due date falls back to before', () {
  expect(phaseFor(_item(), null, null), JourneyChapterKind.before);
});
```

- [ ] **Step 2: Run to verify they fail**

Run: `flutter test test/src/features/journey/domain/journey_phase_test.dart -r compact`
Expected: FAIL — files do not exist.

- [ ] **Step 3: Implement the models and phase inference**

`JourneyNode` fields: `id`, `kind`, `title`, `chapter`, `state`, `dueDate`, `weekNumber`, `sourceId`, `isCompleted`, `submittedAt`, `displayOrder`.

`JourneyChapter`: `kind`, `nodes`, getters `total`, `completed`.

`Journey`: `chapters`, `currentWeek`, `nextAction`, `streak`, `totalNodes`, `completedNodes`, `semesterStart`, `semesterEnd`, `semesterName`; getters `progress`, `isEmpty`, `chapterFor(kind)`, `anchorKind`.

`phaseFor`: explicit `phase` string wins; otherwise compare `dueDate` to semester start/end; otherwise `before`.

`buildJourney` builds nodes and chapters (ordering in Step 5), then fills current/next/streak in Task 4. Return the assembled journey.

- [ ] **Step 4: Write the failing ordering tests**

```dart
test('orders before -> weeks -> during milestone -> after', () {
  final journey = buildJourney(
    checklist: [
      _item(title: 'Offer letter', phase: 'before', due: DateTime(2026, 9, 20)),
      _item(title: 'Final report', phase: 'after', due: DateTime(2027, 1, 20)),
      _item(title: 'Mid-term report', phase: 'during', due: DateTime(2026, 11, 6)),
    ],
    weeks: [_week(1, DateTime(2026, 10, 4), submitted: true), _week(2, DateTime(2026, 10, 11))],
    semesterStart: DateTime(2026, 9, 27),
    semesterEnd: DateTime(2027, 1, 31),
    now: DateTime(2026, 10, 30),
  );

  expect(journey.chapterFor(JourneyChapterKind.before)!.nodes.map((n) => n.title), ['Offer letter']);
  expect(journey.chapterFor(JourneyChapterKind.during)!.nodes.map((n) => n.title), ['Week 1', 'Week 2', 'Mid-term report']);
  expect(journey.chapterFor(JourneyChapterKind.after)!.nodes.map((n) => n.title), ['Final report']);
});

test('drops empty chapters', () {
  final journey = buildJourney(checklist: const [], weeks: const [], semesterStart: null, semesterEnd: null, now: DateTime(2026, 10, 30));
  expect(journey.chapters, isEmpty);
  expect(journey.isEmpty, isTrue);
});
```

- [ ] **Step 5: Implement ordering**

- Build `before`, `after`: sort by `dueDate` (nulls last), then `displayOrder`.
- Build weeks: nodes titled `Week N`, chapter `during`; state: submitted → done; past & unsubmitted → missed; current week → current; else open.
- Build `during` milestones; merge weeks + during milestones sorted by date (weeks use `weekEndDate`; milestones use `dueDate`; null milestone dates last), then `displayOrder`.
- Build chapters in `before, during, after` order; remove empty.
- Fill `currentWeek` (first week with `weekEndDate >= today`), `totalNodes`, `completedNodes`.
- `anchorKind`: before placement → before; after final week → after; during → during; no weeks → before; no nodes → before.

- [ ] **Step 6: Run tests and analyse**

Run: `flutter test test/src/features/journey/domain -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/src/features/journey test/src/features/journey
git commit -m "feat(journey): build chapters from coordinator templates and weeks"
```

---

## Task 4: Next action, streak, progress and headline

**Files:**
- Modify: `lib/src/features/journey/domain/build_journey.dart`
- Create: `lib/src/features/journey/domain/journey_copy.dart`
- Test: `test/src/features/journey/domain/journey_summary_test.dart`

**Interfaces:**
- Produces: `Journey.nextAction`, `Journey.streak`, `Journey.progress`.
- Produces: `int streakFor(List<LogbookWeek> weeks, DateTime now)`.
- Produces: `String homeHeadline(Journey journey)` and `String homeSubline(Journey journey)`.

- [ ] **Step 1: Write the failing tests**

```dart
test('prefers an overdue/due-soon milestone over the current week', () {
  final journey = _journeyWith(
    checklist: [_item(title: 'Supervisor form', phase: 'during', due: DateTime(2026, 10, 29))],
    weeks: [_week(7, DateTime(2026, 11, 6))],
    now: DateTime(2026, 10, 30),
  );
  expect(journey.nextAction!.title, 'Supervisor form');
});
test('falls back to the current week', () {
  final journey = _journeyWith(weeks: [_week(7, DateTime(2026, 11, 6))], now: DateTime(2026, 10, 30));
  expect(journey.nextAction!.title, 'Week 7');
});
test('streak counts on-time weeks and stops at a missed week', () {
  final weeks = [
    _week(1, ..., submitted: true, submittedAt: onTime),
    _week(2, ..., submitted: true, submittedAt: onTime),
    _week(3, ..., submitted: false),
  ];
  expect(streakFor(weeks, now), 0);
  expect(streakFor([_week(1, ..., submitted: true), _week(2, ..., submitted: true)], now), 2);
});
test('late submission breaks the streak', ...);
test('the in-progress week does not break the streak', ...);
test('legacy submitted with null submitted_at counts', ...);
test('headline changes with the anchor', ...);
```

- [ ] **Step 2: Run to verify they fail**

Run: `flutter test test/src/features/journey/domain/journey_summary_test.dart -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement `nextAction`**

Priority:
1. incomplete milestones with `dueDate <= now + 7 days`, earliest first (overdue included);
2. current week if unsubmitted;
3. first incomplete node in chapter order;
4. null.

- [ ] **Step 4: Implement `streakFor`**

- Take weeks whose `weekEndDate` has passed, newest first.
- Count while `isSubmitted` and (`submittedAt == null` or `submittedAt <= end of weekEndDate`).
- Stop at the first missed/late week.
- The in-progress week is excluded.

- [ ] **Step 5: Implement copy**

`homeHeadline`:
- no nodes → `Your journey starts here.`
- before anchor → `Let's get you ready.`
- after anchor, all complete → `You did it.`
- after anchor, incomplete → `The final stretch.`
- during, current/total < 34% → `Early days.`
- < 67% → `Halfway there!`
- otherwise → `The final stretch.`

`homeSubline`: `X weeks to go`, `X milestones left`, or the current week range.

- [ ] **Step 6: Run tests and analyse**

Run: `flutter test test/src/features/journey/domain -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/src/features/journey test/src/features/journey
git commit -m "feat(journey): derive next action, streak and home copy"
```

---

## Task 5: Core UI primitives

**Files:**
- Create: `lib/src/app/ui/buddy_scaffold.dart`
- Create: `lib/src/app/ui/buddy_top_bar.dart`
- Create: `lib/src/app/ui/primary_button.dart`
- Create: `lib/src/app/ui/streak_badge.dart`
- Create: `lib/src/app/ui/chapter_pill.dart`
- Create: `lib/src/app/ui/empty_state.dart`
- Create: `lib/src/app/ui/ui.dart`
- Test: `test/src/app/ui/primary_button_test.dart`
- Test: `test/src/app/ui/streak_badge_test.dart`
- Test: `test/src/app/ui/chapter_pill_test.dart`
- Test: `test/src/app/ui/buddy_top_bar_test.dart`

**Interfaces:**
- `BuddyScaffold({required List<Widget> slivers, Widget? topBar, Future<void> Function()? onRefresh})`
- `BuddyTopBar({required String brand, required int streak, required VoidCallback onProfile, required Widget bell, VoidCallback? onBack})`
- `PrimaryButton({required String label, required VoidCallback? onPressed, IconData? icon, bool sun = false, bool expand = true})`
- `StreakBadge({required int streak, bool compact = false})`
- `ChapterPill({required String title, required int done, required int total, required VoidCallback onTap, bool locked = false})`
- `EmptyState({required String headline, required String body, required String actionLabel, required VoidCallback onAction})`

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('primary button taps and keeps 48px', ...);
testWidgets('disabled primary button does nothing', ...);
testWidgets('streak badge reads 6-week streak', ...);
testWidgets('streak badge says Start a streak at 0', ...);
testWidgets('chapter pill shows 4 / 4 and reports tap', ...);
testWidgets('top bar shows brand, streak and a labelled profile action', ...);
```

- [ ] **Step 2: Run to verify they fail**

Run: `flutter test test/src/app/ui -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement the primitives**

- `BuddyScaffold`: page background, `SafeArea(top: false)`, optional top bar, `RefreshIndicator` around a `CustomScrollView` of the slivers.
- `BuddyTopBar`: brand left (`INTRA BUDDY`, `BUDDY` in blue), row of streak pill, bell, avatar; back arrow when `onBack != null`; avatar 48px target + `Semantics(label: 'Profile')`.
- `PrimaryButton`: 48px, blue fill, white text, `0 4px 0 blueDeep`; `sun: true` uses sun fill, `sunText`, `0 5px 0 sunDeep`; disabled 40% opacity.
- `StreakBadge`: flame icon + `6-week streak` / `Start a streak`; optional dot row.
- `ChapterPill`: white pill, 1.5px line border, coloured dot, title uppercase, `done / total`; locked uses dashed lineStrong.
- `EmptyState`: Fredoka headline, Nunito body, PrimaryButton.

- [ ] **Step 4: Run tests and analyse**

Run: `flutter test test/src/app/ui -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/src/app/ui test/src/app/ui
git commit -m "feat(ui): add blue trail primitives"
```

---

## Task 6: Trail components

**Files:**
- Create: `lib/src/features/journey/presentation/widgets/trail_node.dart`
- Create: `lib/src/features/journey/presentation/widgets/trail_chapter.dart`
- Create: `lib/src/features/journey/presentation/widgets/current_task_card.dart`
- Create: `lib/src/features/journey/presentation/widgets/week_track.dart`
- Create: `lib/src/features/journey/presentation/widgets/milestone_row.dart`
- Test: `test/src/features/journey/presentation/widgets/trail_node_test.dart`
- Test: `test/src/features/journey/presentation/widgets/current_task_card_test.dart`
- Test: `test/src/features/journey/presentation/widgets/week_track_test.dart`

**Interfaces:**
- `TrailNode({required JourneyNode node, required bool isNext, required VoidCallback onTap})`
- `TrailChapter({required JourneyChapter chapter, required String? nextActionId, required ValueChanged<JourneyNode> onNodeTap})`
- `CurrentTaskCard({required JourneyNode? node, required String dueLabel, required String actionLabel, required VoidCallback? onAction})`
- `WeekTrack({required List<JourneyNode> weeks, required ValueChanged<JourneyNode> onTap})`
- `MilestoneRow({required JourneyNode node, required VoidCallback onTap})`

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('week node reads its number and state', ...);
testWidgets('milestone node uses a rounded square and check when done', ...);
testWidgets('missed node is labelled Missed', ...);
testWidgets('current task card shows title, due label and action', ...);
testWidgets('week track marks the current week', ...);
testWidgets('2x text does not overflow a trail node row', ...);
```

- [ ] **Step 2: Run to verify they fail**

Run: `flutter test test/src/features/journey/presentation/widgets -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement the components**

- Week node: 38px circle; done blue + white check; current 64px sun + sunText; future white dashed; missed alert + white exclamation.
- Milestone node: 34px rounded square; done blue + check; open white + line border; overdue alert wash + alert exclamation; locked dashed lineStrong.
- Connector line: 6px vertical blue→line; current segment sun.
- `TrailChapter`: chapter header (overlined title + count), nodes with connector, tap targets.
- `CurrentTaskCard`: white card, overline "UP NEXT", title, due/subtitle, PrimaryButton.
- `WeekTrack`: 1..N small circles, current larger, done blue, future dashed; horizontal scroll if needed.
- `MilestoneRow`: white row, rounded-square state, title, trailing due/check.
- Semantics on every node: "Week 7, current, due Friday" etc.

- [ ] **Step 4: Run tests and analyse**

Run: `flutter test test/src/features/journey/presentation/widgets -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/journey/presentation/widgets test/src/features/journey/presentation/widgets
git commit -m "feat(journey): add trail, week track and task card"
```

---

## Task 7: Journey provider and Home screen

**Files:**
- Create: `lib/src/features/journey/presentation/providers/journey_provider.dart`
- Create: `lib/src/features/journey/presentation/screens/home_screen.dart`
- Create: `lib/src/features/journey/presentation/widgets/home_view.dart`
- Test: `test/src/features/journey/presentation/home_view_test.dart`
- Test: `test/src/features/journey/presentation/providers/journey_provider_test.dart` (pure mapping only if extracted)

**Interfaces:**
- `final journeyProvider = FutureProvider<Journey>((ref) async {...});`
- `HomeView({required Journey journey, required String userName, required Widget bell, required VoidCallback onProfile, required VoidCallback onJourney, required ValueChanged<JourneyNode> onAction, required Future<void> Function() onRefresh})`

- [ ] **Step 1: Write the failing HomeView test**

```dart
testWidgets('shows the headline, next card, chapter pill and current node', (tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: HomeView(
      journey: _sampleJourney(),
      userName: 'Aisyah',
      bell: const SizedBox(),
      onProfile: () {},
      onJourney: () {},
      onAction: (_) {},
      onRefresh: () async {},
    ),
  ));
  expect(find.textContaining('Halfway'), findsOneWidget);
  expect(find.text('Logbook week 7'), findsOneWidget);
  expect(find.textContaining('GETTING READY'), findsOneWidget);
});

testWidgets('shows the empty state when the journey is empty', ...);

testWidgets('does not overflow at 2x text scale', (tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: HomeView(...sample...),
    ),
  ));
  expect(tester.takeException(), isNull);
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/src/features/journey/presentation/home_view_test.dart -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement the provider**

`journeyProvider`:
- watch auth/supabase.
- if no user → `Journey.empty()`.
- load semester (`student_semesters` → `semesters(name,start_date,end_date)`; fallback active semester).
- load checklist via `checklistRepositoryProvider.loadChecklist()`.
- load weeks via `logbookRepositoryProvider.loadExistingWeeks()`.
- `buildJourney(...)` with `DateTime.now()`.

No writes beyond the existing checklist generation.

- [ ] **Step 4: Implement HomeView**

- `BuddyScaffold` with `topBar: BuddyTopBar(...)` and slivers:
  - hero (`WEEK {currentWeek} OF {totalWeeks}`, `homeHeadline`, `homeSubline`);
  - `CurrentTaskCard` (next action; if null, "You're all caught up");
  - past chapters as `ChapterPill`s;
  - current `TrailChapter` with all nodes;
  - future chapters as `ChapterPill`/teaser;
  - `StreakBadge` card;
  - "View full journey" `TextLink`/text button → `onJourney`.
- Auto-scroll to the current week's node once on first build using a `GlobalKey` + `Scrollable.ensureVisible`.
- Show a "Jump to now" chip if the current node is off-screen (optional for this phase; if time, implement).
- No dock inside Home; the shell owns it.

- [ ] **Step 5: Implement HomeScreen**

- Watch `journeyProvider`, `authControllerProvider`, notifications.
- Loading: skeleton chapter blocks.
- Error: `EmptyState`-style error with "Try again".
- Data: `HomeView`.
- `onAction` calls the celebration flow (Task 9); for now, show the confirmation sheet and toggle, then navigate/refresh.

- [ ] **Step 6: Run tests and analyse**

Run: `flutter test test/src/features/journey -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/src/features/journey test/src/features/journey
git commit -m "feat(journey): rebuild Home as the chaptered trail"
```

---

## Task 8: Your Journey screen

**Files:**
- Create: `lib/src/features/journey/presentation/screens/your_journey_screen.dart`
- Create: `lib/src/features/journey/presentation/widgets/your_journey_view.dart`
- Test: `test/src/features/journey/presentation/your_journey_view_test.dart`

**Interfaces:**
- `YourJourneyView({required Journey journey, required ValueChanged<JourneyNode> onNodeTap, required VoidCallback onBack})`

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('shows all three chapters and the journey progress', (tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: YourJourneyView(journey: _sampleJourney(), onNodeTap: (_) {}, onBack: () {}),
  ));
  expect(find.textContaining('GETTING READY'), findsOneWidget);
  expect(find.textContaining('THE INTERNSHIP'), findsOneWidget);
  expect(find.textContaining('WRAPPING UP'), findsOneWidget);
  expect(find.textContaining('Journey progress'), findsOneWidget);
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/src/features/journey/presentation/your_journey_view_test.dart -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement the screen**

- `BuddyScaffold` with a top bar back arrow.
- Hero: "The whole story." + counts.
- Chapter blocks with a left rail: `ChapterPill`/header, then `MilestoneRow`s for before/after and `WeekTrack` for during; during milestones as `MilestoneRow`s under the track.
- Progress bar + `X of Y done`.
- Tapping opens the node (week → logbook; milestone → checklist).
- Empty chapters hidden.

- [ ] **Step 4: Run tests and analyse**

Run: `flutter test test/src/features/journey -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/journey test/src/features/journey
git commit -m "feat(journey): add the full journey screen"
```

---

## Task 9: Celebration overlay and action flow

**Files:**
- Create: `lib/src/features/journey/presentation/widgets/celebration_overlay.dart`
- Create: `lib/src/features/journey/presentation/celebration_controller.dart`
- Modify: `lib/src/features/journey/presentation/screens/home_screen.dart`
- Test: `test/src/features/journey/presentation/celebration_overlay_test.dart`

**Interfaces:**
- `CelebrationOverlay({required String headline, required String subline, required int streak, required double progress, required VoidCallback onContinue})`
- `Future<void> celebrate({required BuildContext context, required JourneyNode node, required Journey journey})`

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('shows the headline, streak and continue action', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: CelebrationOverlay(
      headline: 'Week 7 done!',
      subline: '5 to go',
      streak: 6,
      progress: 0.58,
      onContinue: () {},
    ),
  ));
  expect(find.textContaining('Week 7'), findsOneWidget);
  expect(find.textContaining('6-week streak'), findsOneWidget);
  await tester.tap(find.text('Keep going'));
  expect(continued, isTrue);
});

testWidgets('reduced motion still shows the result', ...);
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/src/features/journey/presentation/celebration_overlay_test.dart -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement the overlay**

- Full-screen blue background, white card, confetti painter (blue/sky/sun/white), white check circle, headline `Week N done!` / `Milestone done!`, subline, streak badge, progress bar, `SunButton` "Keep going".
- `CustomPainter` or a small particle list with `AnimationController` 900ms; dispose. Reduced motion → static confetti/no animation.
- `showGeneralDialog` with a transparent barrier; no auto-dismiss.

- [ ] **Step 4: Implement the action flow**

In `HomeScreen`:
- Confirm sheet: week → "Mark week N as submitted?" + the portal note; milestone → "Mark this milestone as done?".
- On confirm:
  - `await ref.read(logbookControllerProvider.future)`; `toggleSubmitted(node.sourceId!, true)`.
  - or `await ref.read(checklistControllerProvider.future)`; `toggleItem(node.sourceId!, true)`.
  - if failure → SnackBar "Couldn't update. Try again."
  - if success → `ref.invalidate(journeyProvider)`; `await ref.read(journeyProvider.future)`; show celebration with the updated journey.
- Undo never celebrates. Re-marking after undo may celebrate again.
- Copy uses "marked submitted", not "submitted to the portal".

- [ ] **Step 5: Run tests and analyse**

Run: `flutter test test/src/features/journey -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 6: Commit**

```bash
git add lib/src/features/journey test/src/features/journey
git commit -m "feat(journey): add the weekly celebration and action flow"
```

---

## Task 10: Blue shell, dock and routing

**Files:**
- Create: `lib/src/app/ui/buddy_dock.dart`
- Modify: `lib/src/features/dashboard/presentation/screens/student_shell.dart`
- Modify: `lib/src/app/router.dart`
- Modify: `lib/src/app/ui/ui.dart`
- Test: `test/src/app/ui/buddy_dock_test.dart`
- Test: `test/src/app/router_test.dart` (only if needed)

**Interfaces:**
- `BuddyDock({required int currentIndex, required ValueChanged<int> onSelected})` with labels Home, Checklist, Jobs, INTRA.

- [ ] **Step 1: Write the failing dock test**

```dart
testWidgets('shows four labelled tabs and stays compact in the bottom bar', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: const Text('Page'),
      bottomNavigationBar: BuddyDock(currentIndex: 0, onSelected: (_) {}),
    ),
  ));
  expect(find.text('Home'), findsOneWidget);
  expect(find.text('INTRA'), findsOneWidget);
  expect(tester.getSize(find.byType(BuddyDock)).height, lessThan(100));
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/src/app/ui/buddy_dock_test.dart -r compact`
Expected: FAIL.

- [ ] **Step 3: Implement the dock and shell**

- `BuddyDock`: white rounded bar, blue 3D? A soft shadow; active blue icon/label; inactive muted; `MainAxisSize.min` in the item columns (the premium branch proved this; include a regression test).
- `StudentShell`: `Scaffold(backgroundColor: page, body: navigationShell, bottomNavigationBar: SafeArea(top:false, child: BuddyDock(...)))`; keep `currentTabIndexProvider` sync; remove the five-icon bar and More sheet.
- Router: `/dashboard` → `HomeScreen`; add `/journey` → `YourJourneyScreen` with `parentNavigatorKey: appRootNavigatorKey`.
- Home top bar profile → `/profile`; bell → `/notifications`.
- Keep the old Checklist/Jobs/Chat routes and screens; they will be restyled later.

- [ ] **Step 4: Run tests and analyse**

Run: `flutter test -r compact`
Run: `flutter analyze`
Expected: PASS / no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/src/app/ui/buddy_dock.dart lib/src/features/dashboard/presentation/screens/student_shell.dart lib/src/app/router.dart test/src/app/ui/buddy_dock_test.dart
git commit -m "feat(shell): replace the dashboard shell with the blue dock"
```

---

## Task 11: Remove the old dashboard and verify

**Files:**
- Delete: `lib/src/features/dashboard/presentation/screens/dashboard_home.dart`
- Delete: `lib/src/features/dashboard/presentation/widgets/journey_card.dart`
- Delete: `lib/src/features/dashboard/presentation/journey_progress.dart`
- Delete: `lib/src/features/dashboard/presentation/providers/dashboard_controller.dart`
- Delete: `test/src/features/dashboard/presentation/widgets/journey_card_test.dart`
- Delete: `test/src/features/dashboard/presentation/journey_progress_test.dart`
- Modify: anything the analyzer flags.

- [ ] **Step 1: Delete the replaced dashboard**

Run the deletions above.

- [ ] **Step 2: Find leftovers**

```bash
grep -rn "DashboardHome\|JourneyCard\|JourneyProgress\|dashboardProvider\|LatestNotificationBanner" lib test
grep -rn "Colors\.white\|Colors\.black" lib/src/features/journey lib/src/app/ui
```

Expected: no live references. `LatestNotificationBanner` may remain unused; it is rebuilt in a later phase.

- [ ] **Step 3: Full verification**

```bash
flutter analyze
flutter test -r compact
```

Expected: analyze clean; all tests pass.

- [ ] **Step 4: Manual smoke test**

On a physical Android phone (or 375×667 emulator), light theme:

- The trail opens on the current week.
- The current card marks the week and shows the celebration.
- The chapter pills open Your Journey; the weeks and milestones match the coordinator data.
- Text scale 2.0 does not clip the card, pills or nodes.
- Reduced motion still shows the result.
- Tapping a future week does nothing destructive; tapping a missed week opens the logbook.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: remove the old dashboard and finish the trail polish"
```

---

## Execution Notes

- Do not restyle Checklist/Logbook/Jobs/Assistant/Documents/Profile/Auth in this plan; they get their own plans.
- No writes beyond the existing checklist toggle and logbook status update.
- The `phase`/`due_date` columns are already live; do not add more schema.
- If tests need Supabase, extract a pure function instead; the suite stays offline.
- The legacy 14-week seed is out of scope; render existing rows.
