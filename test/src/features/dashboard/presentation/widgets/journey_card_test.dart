import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/dashboard/presentation/journey_progress.dart';
import 'package:intra_buddy_mobile_v2/src/features/dashboard/presentation/widgets/journey_card.dart';

List<JourneyWeekStatus> _states({
  required int completed,
  required int missed,
  int? current,
}) {
  return [
    for (var n = 1; n <= 14; n++)
      JourneyWeekStatus(
        weekNumber: n,
        endDate: DateTime(2026, 9, 27).add(Duration(days: 7 * n)),
        submitted: n <= completed,
        missed: current == null
            ? n > completed
            : (missed > 0 && n == completed + 1),
        current: n == current,
      ),
  ];
}

JourneyProgress _progress({
  JourneyPhase phase = JourneyPhase.inProgress,
  int? currentWeek = 5,
  int completed = 5,
  int missed = 0,
  int remaining = 9,
  int? nextWeek = 6,
  DateTime? nextDeadline,
}) {
  return JourneyProgress(
    phase: phase,
    totalWeeks: 14,
    completedWeeks: completed,
    missedWeeks: missed,
    remainingWeeks: remaining,
    currentWeek: currentWeek,
    nextWeekNumber: nextWeek,
    nextDeadline: nextDeadline ?? DateTime(2026, 11, 8),
    weekStates: _states(
      completed: completed,
      missed: missed,
      current: currentWeek,
    ),
  );
}

Widget _harness(JourneyProgress progress) {
  return MaterialApp(
    home: Scaffold(
      body: JourneyCard(
        progress: progress,
        semesterStart: DateTime(2026, 9, 27),
        semesterEnd: DateTime(2027, 1, 31),
        milestonesDone: 2,
        milestonesTotal: 4,
        onChecklist: () {},
        onLogbook: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the current week and the journey counts', (tester) async {
    await tester.pumpWidget(_harness(_progress()));

    expect(find.text('Week 5 of 14'), findsOneWidget);
    expect(find.textContaining('5 done'), findsOneWidget);
    expect(find.textContaining('9 to go'), findsOneWidget);
    expect(find.textContaining('Week 6 ends'), findsOneWidget);
    expect(find.textContaining('2 of 4 milestones'), findsOneWidget);
  });

  testWidgets('shows missed weeks separately', (tester) async {
    await tester.pumpWidget(
      _harness(
        _progress(
          completed: 3,
          missed: 1,
          remaining: 10,
          nextWeek: 5,
          nextDeadline: DateTime(2026, 11, 1),
        ),
      ),
    );

    expect(find.textContaining('1 missed'), findsOneWidget);
    expect(find.textContaining('10 to go'), findsOneWidget);
  });

  testWidgets('shows a start date before the internship begins', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _progress(
          phase: JourneyPhase.notStarted,
          currentWeek: null,
          completed: 0,
          remaining: 14,
          nextWeek: 1,
          nextDeadline: DateTime(2026, 10, 4),
        ),
      ),
    );

    expect(find.textContaining('Starts 27 Sep'), findsOneWidget);
    expect(find.textContaining('14 weeks'), findsOneWidget);
  });

  testWidgets('shows completion after the last week', (tester) async {
    await tester.pumpWidget(
      _harness(
        _progress(
          phase: JourneyPhase.finished,
          currentWeek: null,
          completed: 10,
          missed: 4,
          remaining: 0,
          nextWeek: null,
          nextDeadline: null,
        ),
      ),
    );

    expect(find.text('Journey complete'), findsOneWidget);
    expect(find.textContaining('10 done'), findsOneWidget);
    expect(find.textContaining('4 missed'), findsOneWidget);
  });

  testWidgets('prompts setup when there are no weeks yet', (tester) async {
    await tester.pumpWidget(
      _harness(
        const JourneyProgress(
          phase: JourneyPhase.inProgress,
          totalWeeks: 0,
          completedWeeks: 0,
          missedWeeks: 0,
          remainingWeeks: 0,
          currentWeek: null,
          nextWeekNumber: null,
          nextDeadline: null,
          weekStates: [],
        ),
      ),
    );

    expect(find.textContaining('Logbook not set up yet'), findsOneWidget);
  });
}
