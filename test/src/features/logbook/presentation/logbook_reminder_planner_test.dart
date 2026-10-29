import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_reminder_planner.dart';

ReminderWeek _week(int number, String end, {bool submitted = false}) =>
    ReminderWeek(
      weekNumber: number,
      endDate: DateTime.parse(end),
      isSubmitted: submitted,
    );

void main() {
  final now = DateTime(2026, 10, 30, 8);

  test('schedules the day before at 09:00 for unsubmitted weeks', () {
    final plan = planLogbookReminders(
      weeks: [_week(6, '2026-11-08')],
      now: now,
    );

    expect(plan, hasLength(1));
    expect(plan.single.weekNumber, 6);
    expect(plan.single.scheduledAt, DateTime(2026, 11, 7, 9));
    expect(plan.single.id, 5006);
    expect(plan.single.title, 'Week 6 logbook due tomorrow');
    expect(plan.single.body, contains('8 Nov 2026'));
  });

  test('skips submitted weeks', () {
    final plan = planLogbookReminders(
      weeks: [_week(6, '2026-11-08', submitted: true)],
      now: now,
    );

    expect(plan, isEmpty);
  });

  test('skips reminders whose time has already passed', () {
    final plan = planLogbookReminders(
      weeks: [
        _week(4, '2026-10-25'), // reminder was 24 Oct
        _week(5, '2026-11-01'), // reminder is 31 Oct 09:00
      ],
      now: now,
    );

    expect(plan.map((r) => r.weekNumber), [5]);
  });

  test('sorts by scheduled time', () {
    final plan = planLogbookReminders(
      weeks: [
        _week(8, '2026-11-22'),
        _week(6, '2026-11-08'),
        _week(7, '2026-11-15'),
      ],
      now: now,
    );

    expect(plan.map((r) => r.weekNumber), [6, 7, 8]);
  });

  test('includes a reminder that is still in the future today', () {
    final plan = planLogbookReminders(
      weeks: [_week(5, '2026-10-31')], // reminder today at 09:00
      now: now,
    );

    expect(plan, hasLength(1));
    expect(plan.single.scheduledAt, DateTime(2026, 10, 30, 9));
  });

  test('handles an empty week list', () {
    expect(planLogbookReminders(weeks: const [], now: now), isEmpty);
  });
}
