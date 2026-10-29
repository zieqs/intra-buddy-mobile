import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/entities/logbook_week.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_week_info.dart';

LogbookWeek _week(
  int number,
  DateTime end, {
  bool submitted = false,
  DateTime? submittedAt,
}) {
  return LogbookWeek(
    id: number,
    weekNumber: number,
    weekEndDate: end,
    isSubmitted: submitted,
    submittedAt:
        submittedAt ??
        (submitted ? end.subtract(const Duration(days: 1)) : null),
  );
}

List<LogbookWeek> _fourteen({
  int submittedThrough = 0,
  Set<int> unsubmitted = const {},
}) {
  final start = DateTime(2026, 9, 27);
  return [
    for (var n = 1; n <= 14; n++)
      _week(
        n,
        start.add(Duration(days: 7 * n)),
        submitted: n <= submittedThrough && !unsubmitted.contains(n),
      ),
  ];
}

void main() {
  final now = DateTime(2026, 10, 29);

  test('finds the current week and flags a deadline within three days', () {
    final summary = buildLogbookSummary(
      _fourteen(unsubmitted: {1, 2, 3, 4}),
      now,
    );

    expect(summary.currentWeek, 5);
    expect(summary.current?.state, LogbookWeekState.dueSoon);
    expect(summary.current?.daysUntilDue, 3);
    expect(summary.current?.canSubmit, isTrue);
  });

  test(
    'treats the current week as normal when the deadline is further out',
    () {
      final summary = buildLogbookSummary(
        _fourteen(unsubmitted: {1, 2, 3, 4}),
        DateTime(2026, 10, 27),
      );

      expect(summary.currentWeek, 5);
      expect(summary.current?.state, LogbookWeekState.current);
      expect(summary.current?.daysUntilDue, 5);
    },
  );

  test('marks past unsubmitted weeks as missed and still submittable', () {
    final summary = buildLogbookSummary(
      _fourteen(submittedThrough: 3, unsubmitted: {4}),
      now,
    );
    final week4 = summary.weeks.firstWhere((w) => w.week.weekNumber == 4);

    expect(week4.state, LogbookWeekState.missed);
    expect(week4.canSubmit, isTrue);
    expect(week4.daysUntilDue, isNegative);
    expect(summary.missedWeeks, 1);
  });

  test('future weeks are upcoming and cannot be submitted', () {
    final summary = buildLogbookSummary(_fourteen(), now);
    final week6 = summary.weeks.firstWhere((w) => w.week.weekNumber == 6);

    expect(week6.state, LogbookWeekState.upcoming);
    expect(week6.canSubmit, isFalse);
  });

  test('submitted wins over every other state', () {
    final summary = buildLogbookSummary(_fourteen(submittedThrough: 5), now);
    final week5 = summary.weeks.firstWhere((w) => w.week.weekNumber == 5);

    expect(week5.state, LogbookWeekState.submitted);
    expect(week5.canSubmit, isFalse);
    expect(summary.currentWeek, 5);
    expect(summary.current?.state, LogbookWeekState.submitted);
  });

  test('reports completion after the last week ends', () {
    final summary = buildLogbookSummary(
      _fourteen(submittedThrough: 10),
      DateTime(2027, 1, 10),
    );

    expect(summary.isFinished, isTrue);
    expect(summary.currentWeek, isNull);
    expect(summary.current, isNull);
    expect(summary.missedWeeks, 4);
  });

  test('handles an empty logbook', () {
    final summary = buildLogbookSummary(const [], now);

    expect(summary.totalWeeks, 0);
    expect(summary.completedWeeks, 0);
    expect(summary.currentWeek, isNull);
    expect(summary.weeks, isEmpty);
  });

  test('keeps weeks sorted by week number', () {
    final weeks = _fourteen()..shuffle();
    final summary = buildLogbookSummary(weeks, now);

    expect(
      summary.weeks.map((w) => w.week.weekNumber),
      List.generate(14, (i) => i + 1),
    );
  });
}
