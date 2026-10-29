import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/dashboard/presentation/journey_progress.dart';

JourneyWeek _week(int number, String end, {bool submitted = false}) =>
    JourneyWeek(
      weekNumber: number,
      endDate: DateTime.parse(end),
      isSubmitted: submitted,
    );

List<JourneyWeek> _fourteen({
  int submittedThrough = 0,
  Set<int> missed = const {},
}) {
  return [
    for (var n = 1; n <= 14; n++)
      _week(
        n,
        DateTime(
          2026,
          9,
          27,
        ).add(Duration(days: 7 * n)).toIso8601String().split('T').first,
        submitted: n <= submittedThrough && !missed.contains(n),
      ),
  ];
}

void main() {
  test('is not started before the semester start', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: _fourteen(),
      now: DateTime(2026, 9, 20),
    );

    expect(progress.phase, JourneyPhase.notStarted);
    expect(progress.currentWeek, isNull);
    expect(progress.completedWeeks, 0);
    expect(progress.missedWeeks, 0);
    expect(progress.remainingWeeks, 14);
  });

  test('reports the current week and counts mid-journey', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: _fourteen(submittedThrough: 5),
      now: DateTime(2026, 10, 29),
    );

    expect(progress.phase, JourneyPhase.inProgress);
    expect(progress.currentWeek, 5);
    expect(progress.completedWeeks, 5);
    expect(progress.missedWeeks, 0);
    expect(progress.remainingWeeks, 9);
    expect(progress.nextWeekNumber, 6);
    expect(progress.nextDeadline, DateTime(2026, 11, 8));
  });

  test('counts past unsubmitted weeks as missed', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: _fourteen(submittedThrough: 3, missed: {4}),
      now: DateTime(2026, 10, 29),
    );

    expect(progress.currentWeek, 5);
    expect(progress.completedWeeks, 3);
    expect(progress.missedWeeks, 1);
    expect(progress.remainingWeeks, 10);
  });

  test('a week is not missed on its due date', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: _fourteen(submittedThrough: 4),
      now: DateTime(2026, 11, 1),
    );

    expect(progress.currentWeek, 5);
    expect(progress.missedWeeks, 0);
    expect(progress.nextWeekNumber, 5);
    expect(progress.nextDeadline, DateTime(2026, 11, 1));
  });

  test('is finished after the last week ends', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: _fourteen(submittedThrough: 10),
      now: DateTime(2027, 1, 10),
    );

    expect(progress.phase, JourneyPhase.finished);
    expect(progress.currentWeek, isNull);
    expect(progress.completedWeeks, 10);
    expect(progress.missedWeeks, 4);
    expect(progress.remainingWeeks, 0);
    expect(progress.nextWeekNumber, isNull);
  });

  test('has nothing next when every week is submitted', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: _fourteen(submittedThrough: 14),
      now: DateTime(2026, 10, 29),
    );

    expect(progress.completedWeeks, 14);
    expect(progress.remainingWeeks, 0);
    expect(progress.nextWeekNumber, isNull);
    expect(progress.nextDeadline, isNull);
  });

  test('handles a semester with no weeks yet', () {
    final progress = computeJourneyProgress(
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2027, 1, 31),
      weeks: const [],
      now: DateTime(2026, 10, 29),
    );

    expect(progress.totalWeeks, 0);
    expect(progress.phase, JourneyPhase.inProgress);
    expect(progress.remainingWeeks, 0);
  });
}
