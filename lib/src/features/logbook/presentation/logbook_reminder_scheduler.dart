import 'logbook_reminder_planner.dart';

/// The scheduling side of logbook reminders, kept behind an interface so the
/// mapping from the journey can be tested without the platform plugin.
abstract interface class LogbookReminderScheduler {
  Future<void> reschedule(List<ReminderWeek> weeks);
}
