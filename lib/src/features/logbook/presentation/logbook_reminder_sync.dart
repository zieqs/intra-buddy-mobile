import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journey/domain/journey.dart';
import 'logbook_reminder_planner.dart';
import 'logbook_reminder_scheduler.dart';
import 'services/logbook_reminder_service.dart';

export 'logbook_reminder_scheduler.dart';

final logbookReminderSchedulerProvider = Provider<LogbookReminderScheduler>(
  (ref) => LogbookReminderService.instance,
);

List<ReminderWeek> reminderWeeksFromJourney(Journey journey) {
  final chapter = journey.chapterFor(JourneyChapterKind.during);
  if (chapter == null) return const [];

  return [
    for (final node in chapter.nodes)
      if (node.isWeek && node.weekNumber != null && node.dueDate != null)
        ReminderWeek(
          weekNumber: node.weekNumber!,
          endDate: node.dueDate!,
          isSubmitted: node.isCompleted,
        ),
  ];
}

/// Keeps the device's pending reminders aligned with the current journey.
///
/// An empty schedule is meaningful: it clears reminders for weeks that no
/// longer exist instead of leaving stale ones behind.
Future<void> syncLogbookReminders(
  Journey journey,
  LogbookReminderScheduler scheduler,
) {
  return scheduler.reschedule(reminderWeeksFromJourney(journey));
}
