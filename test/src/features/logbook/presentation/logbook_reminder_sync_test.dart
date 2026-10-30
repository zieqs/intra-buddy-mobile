import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_reminder_planner.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_reminder_sync.dart';

class _FakeScheduler implements LogbookReminderScheduler {
  List<ReminderWeek>? weeks;

  @override
  Future<void> reschedule(List<ReminderWeek> weeks) async {
    this.weeks = weeks;
  }
}

Journey _journey({bool week1Submitted = false}) => Journey(
  chapters: [
    JourneyChapter(
      kind: JourneyChapterKind.during,
      nodes: [
        JourneyNode(
          id: 'week-1',
          kind: JourneyNodeKind.week,
          title: 'Week 1',
          chapter: JourneyChapterKind.during,
          state: JourneyNodeState.done,
          dueDate: DateTime(2026, 11, 8),
          weekNumber: 1,
          isCompleted: week1Submitted,
        ),
        JourneyNode(
          id: 'week-2',
          kind: JourneyNodeKind.week,
          title: 'Week 2',
          chapter: JourneyChapterKind.during,
          state: JourneyNodeState.open,
          dueDate: DateTime(2026, 11, 15),
          weekNumber: 2,
        ),
      ],
    ),
  ],
  totalNodes: 2,
  completedNodes: week1Submitted ? 1 : 0,
);

void main() {
  test('maps weekly journey nodes to reminder weeks', () {
    final weeks = reminderWeeksFromJourney(_journey(week1Submitted: true));

    expect(weeks, hasLength(2));
    expect(weeks.first.weekNumber, 1);
    expect(weeks.first.endDate, DateTime(2026, 11, 8));
    expect(weeks.first.isSubmitted, isTrue);
    expect(weeks.last.weekNumber, 2);
    expect(weeks.last.isSubmitted, isFalse);
  });

  test('has nothing to remind when the journey has no weeks', () {
    expect(reminderWeeksFromJourney(const Journey()), isEmpty);
  });

  test('syncs the reminder schedule with the journey weeks', () async {
    final scheduler = _FakeScheduler();

    await syncLogbookReminders(
      _journey(week1Submitted: true),
      scheduler,
    );

    expect(scheduler.weeks, hasLength(2));
    expect(scheduler.weeks!.first.isSubmitted, isTrue);
  });

  test('syncs an empty schedule so stale reminders are cleared', () async {
    final scheduler = _FakeScheduler();

    await syncLogbookReminders(const Journey(), scheduler);

    expect(scheduler.weeks, isEmpty);
  });
}
