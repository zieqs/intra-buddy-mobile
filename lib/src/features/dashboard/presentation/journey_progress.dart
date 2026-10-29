/// One week of the internship journey as shown on the dashboard.
class JourneyWeek {
  final int weekNumber;
  final DateTime endDate;
  final bool isSubmitted;

  const JourneyWeek({
    required this.weekNumber,
    required this.endDate,
    required this.isSubmitted,
  });
}

enum JourneyPhase { notStarted, inProgress, finished }

class JourneyWeekStatus {
  final int weekNumber;
  final DateTime endDate;
  final bool submitted;
  final bool missed;
  final bool current;

  const JourneyWeekStatus({
    required this.weekNumber,
    required this.endDate,
    required this.submitted,
    required this.missed,
    required this.current,
  });
}

class JourneyProgress {
  final JourneyPhase phase;
  final int totalWeeks;
  final int completedWeeks;
  final int missedWeeks;
  final int remainingWeeks;
  final int? currentWeek;
  final int? nextWeekNumber;
  final DateTime? nextDeadline;
  final List<JourneyWeekStatus> weekStates;

  const JourneyProgress({
    required this.phase,
    required this.totalWeeks,
    required this.completedWeeks,
    required this.missedWeeks,
    required this.remainingWeeks,
    required this.currentWeek,
    required this.nextWeekNumber,
    required this.nextDeadline,
    required this.weekStates,
  });
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Derives the internship journey from the student's logbook weeks.
///
/// Weeks whose end date has passed without a submission are counted as
/// missed; the current week is the first week whose end date is today or
/// later. A week is not considered missed on its due date.
JourneyProgress computeJourneyProgress({
  required DateTime? startDate,
  required DateTime? endDate,
  required List<JourneyWeek> weeks,
  required DateTime now,
}) {
  final today = _dateOnly(now);
  final sorted = [...weeks]
    ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

  final lastWeekEnd = sorted.isEmpty ? null : _dateOnly(sorted.last.endDate);
  final journeyEnd =
      lastWeekEnd ?? (endDate == null ? null : _dateOnly(endDate));
  final journeyStart = startDate == null ? null : _dateOnly(startDate);

  final JourneyPhase phase;
  if (journeyStart != null && today.isBefore(journeyStart)) {
    phase = JourneyPhase.notStarted;
  } else if (journeyEnd != null && today.isAfter(journeyEnd)) {
    phase = JourneyPhase.finished;
  } else {
    phase = JourneyPhase.inProgress;
  }

  final completed = sorted.where((week) => week.isSubmitted).length;
  final missed = sorted
      .where(
        (week) => !week.isSubmitted && _dateOnly(week.endDate).isBefore(today),
      )
      .length;
  final remaining = sorted.length - completed - missed;

  int? currentWeek;
  if (phase == JourneyPhase.inProgress && sorted.isNotEmpty) {
    currentWeek = sorted
        .firstWhere(
          (week) => !_dateOnly(week.endDate).isBefore(today),
          orElse: () => sorted.last,
        )
        .weekNumber;
  }

  final upcoming = sorted.where(
    (week) => !week.isSubmitted && !_dateOnly(week.endDate).isBefore(today),
  );
  final next = upcoming.isEmpty ? null : upcoming.first;

  final weekStates = [
    for (final week in sorted)
      JourneyWeekStatus(
        weekNumber: week.weekNumber,
        endDate: week.endDate,
        submitted: week.isSubmitted,
        missed: !week.isSubmitted && _dateOnly(week.endDate).isBefore(today),
        current: currentWeek != null && week.weekNumber == currentWeek,
      ),
  ];

  return JourneyProgress(
    phase: phase,
    totalWeeks: sorted.length,
    completedWeeks: completed,
    missedWeeks: missed,
    remainingWeeks: remaining,
    currentWeek: currentWeek,
    nextWeekNumber: next?.weekNumber,
    nextDeadline: next?.endDate,
    weekStates: weekStates,
  );
}
