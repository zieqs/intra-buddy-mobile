/// Minimal week data needed to plan a logbook reminder.
class ReminderWeek {
  final int weekNumber;
  final DateTime endDate;
  final bool isSubmitted;

  const ReminderWeek({
    required this.weekNumber,
    required this.endDate,
    required this.isSubmitted,
  });
}

class LogbookReminder {
  final int id;
  final int weekNumber;
  final DateTime scheduledAt;
  final String title;
  final String body;

  const LogbookReminder({
    required this.id,
    required this.weekNumber,
    required this.scheduledAt,
    required this.title,
    required this.body,
  });
}

/// Plans one notification per unsubmitted week, the day before its due date
/// at 09:00 local time. Reminders already in the past are dropped.
List<LogbookReminder> planLogbookReminders({
  required List<ReminderWeek> weeks,
  required DateTime now,
  int hour = 9,
}) {
  final reminders = <LogbookReminder>[];

  for (final week in weeks) {
    if (week.isSubmitted) continue;

    final due = DateTime(
      week.endDate.year,
      week.endDate.month,
      week.endDate.day,
    );
    final scheduledAt = DateTime(
      due.year,
      due.month,
      due.day,
      hour,
    ).subtract(const Duration(days: 1));

    if (!scheduledAt.isAfter(now)) continue;

    reminders.add(
      LogbookReminder(
        id: 5000 + week.weekNumber,
        weekNumber: week.weekNumber,
        scheduledAt: scheduledAt,
        title: 'Week ${week.weekNumber} logbook due tomorrow',
        body:
            'Submit your Week ${week.weekNumber} logbook before ${_formatDate(due)}.',
      ),
    );
  }

  reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return reminders;
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
