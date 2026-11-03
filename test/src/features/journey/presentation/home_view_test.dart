import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/build_journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/current_task_card.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/home_view.dart';

import '../journey_fixtures.dart';

List<dynamic> _weeks12() {
  return List.generate(12, (index) {
    final number = index + 1;
    final end = DateTime(2026, 9, 18).add(Duration(days: 7 * number));
    final submitted = number <= 6;
    return journeyWeek(
      number,
      end,
      submitted: submitted,
      submittedAt: submitted ? end : null,
    );
  });
}

void main() {
  testWidgets('shows the headline, next task and full journey', (
    tester,
  ) async {
    final journey = buildJourney(
      checklist: [
        journeyItem(
          id: 1,
          title: 'Attend INTRA briefing',
          phase: 'before',
          done: true,
        ),
        journeyItem(
          id: 2,
          title: 'Final report',
          phase: 'after',
          due: DateTime(2027, 1, 20),
        ),
      ],
      weeks: _weeks12().cast(),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      semesterName: 'INTRA Session 1',
      now: DateTime(2026, 10, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(
          journey: journey,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onLogbook: () {},
          onAction: (_) {},
          onRefresh: () async {},
          now: DateTime(2026, 10, 31),
        ),
      ),
    );

    expect(find.textContaining('Halfway'), findsOneWidget);
    expect(find.text('Week 7'), findsNWidgets(2));
    expect(find.text('GETTING READY'), findsOneWidget);
    expect(find.text('THE INTERNSHIP'), findsOneWidget);
    expect(find.text('WRAPPING UP'), findsOneWidget);
  });

  testWidgets('shows the empty state when the journey is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(
          journey: buildJourney(
            checklist: const [],
            weeks: const [],
            semesterStart: null,
            semesterEnd: null,
            now: DateTime(2026, 10, 31),
          ),
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onLogbook: () {},
          onAction: (_) {},
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.text('Your journey starts here.'), findsOneWidget);
  });

  testWidgets('does not overflow at 2x text scale', (tester) async {
    final journey = buildJourney(
      checklist: [
        journeyItem(id: 1, title: 'Attend INTRA briefing', phase: 'before'),
      ],
      weeks: _weeks12().cast(),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: HomeView(
            journey: journey,
            userName: 'Aisyah',
            bell: const SizedBox(),
            onProfile: () {},
            onLogbook: () {},
            onAction: (_) {},
            onRefresh: () async {},
            now: DateTime(2026, 10, 31),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('offers the first week when the next node is a future week', (
    tester,
  ) async {
    final journey = buildJourney(
      checklist: [
        journeyItem(
          id: 1,
          title: 'Attend INTRA briefing',
          phase: 'before',
          done: true,
        ),
      ],
      weeks: List.generate(12, (index) {
        final number = index + 1;
        return journeyWeek(
          number,
          DateTime(2026, 9, 18).add(Duration(days: 7 * number)),
        );
      }),
      semesterStart: DateTime(2026, 11, 1),
      semesterEnd: DateTime(2027, 2, 7),
      now: DateTime(2026, 10, 30),
    );

    expect(journey.nextAction?.title, 'Week 1');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(
          journey: journey,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onLogbook: () {},
          onAction: (_) {},
          onRefresh: () async {},
          now: DateTime(2026, 10, 30),
        ),
      ),
    );

    expect(find.text('Open week 1'), findsOneWidget);
  });

  testWidgets('hero shows the flame and the Week 1 streak copy', (
    tester,
  ) async {
    final journey = buildJourney(
      checklist: [
        journeyItem(
          id: 1,
          title: 'Attend INTRA briefing',
          phase: 'before',
          done: true,
        ),
      ],
      weeks: List.generate(12, (index) {
        final number = index + 1;
        return journeyWeek(
          number,
          DateTime(2026, 9, 18).add(Duration(days: 7 * number)),
        );
      }),
      semesterStart: DateTime(2026, 11, 1),
      semesterEnd: DateTime(2027, 2, 7),
      now: DateTime(2026, 10, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(
          journey: journey,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onLogbook: () {},
          onAction: (_) {},
          onRefresh: () async {},
          now: DateTime(2026, 10, 30),
        ),
      ),
    );

    final hero = find.textContaining('Streak starts with Week 1 Submission');
    expect(hero, findsOneWidget);
    expect(
      find.descendant(
        of: hero,
        matching: find.byIcon(Icons.local_fire_department_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps the up-next card out of the journey scroll', (
    tester,
  ) async {
    final journey = buildJourney(
      checklist: [
        for (var i = 0; i < 5; i++)
          journeyItem(id: i + 1, title: 'Ready $i', phase: 'before', done: true),
      ],
      weeks: List.generate(
        12,
        (index) => journeyWeek(
          index + 1,
          DateTime(2026, 11, 8).add(Duration(days: 7 * index)),
        ),
      ),
      semesterStart: DateTime(2026, 11, 1),
      semesterEnd: DateTime(2027, 2, 7),
      now: DateTime(2026, 11, 3),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(
          journey: journey,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onLogbook: () {},
          onAction: (_) {},
          onRefresh: () async {},
          now: DateTime(2026, 11, 3),
        ),
      ),
    );

    expect(find.byType(CurrentTaskCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(CurrentTaskCard),
      ),
      findsNothing,
    );
  });

  testWidgets('opens the journey focused on the current week', (tester) async {
    final journey = buildJourney(
      checklist: [
        for (var i = 0; i < 5; i++)
          journeyItem(id: i + 1, title: 'Ready $i', phase: 'before', done: true),
      ],
      weeks: List.generate(
        12,
        (index) => journeyWeek(
          index + 1,
          DateTime(2026, 11, 8).add(Duration(days: 7 * index)),
        ),
      ),
      semesterStart: DateTime(2026, 11, 1),
      semesterEnd: DateTime(2027, 2, 7),
      now: DateTime(2026, 11, 3),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(
          journey: journey,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onLogbook: () {},
          onAction: (_) {},
          onRefresh: () async {},
          now: DateTime(2026, 11, 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      greaterThan(0),
    );
  });
}
