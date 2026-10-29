import '../domain/entities/logbook_week.dart';

enum LogbookWeekState { submitted, missed, dueSoon, current, upcoming }

class LogbookWeekInfo {
  final LogbookWeek week;
  final LogbookWeekState state;

  /// Days from today to the due date; negative once the deadline has passed.
  final int daysUntilDue;

  /// Past and current weeks can be marked; future weeks cannot.
  final bool canSubmit;

  const LogbookWeekInfo({
    required this.week,
    required this.state,
    required this.daysUntilDue,
    required this.canSubmit,
  });
}

class LogbookSummary {
  final int totalWeeks;
  final int completedWeeks;
  final int missedWeeks;
  final int? currentWeek;
  final LogbookWeekInfo? current;
  final bool isFinished;
  final List<LogbookWeekInfo> weeks;

  const LogbookSummary({
    required this.totalWeeks,
    required this.completedWeeks,
    required this.missedWeeks,
    required this.currentWeek,
    required this.current,
    required this.isFinished,
    required this.weeks,
  });
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Derives the per-week state used by the logbook screen.
///
/// A week is "due soon" when it is the current week and ends within three days.
/// Missed weeks stay submittable (late), while future weeks do not.
LogbookSummary buildLogbookSummary(List<LogbookWeek> weeks, DateTime now) {
  final today = _dateOnly(now);
  final sorted = [...weeks]
    ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

  int? currentWeek;
  for (final week in sorted) {
    if (!_dateOnly(week.weekEndDate).isBefore(today)) {
      currentWeek = week.weekNumber;
      break;
    }
  }

  final infos = <LogbookWeekInfo>[];
  LogbookWeekInfo? currentInfo;

  for (final week in sorted) {
    final end = _dateOnly(week.weekEndDate);
    final daysUntilDue = end.difference(today).inDays;
    final isCurrent = week.weekNumber == currentWeek;

    final LogbookWeekState state;
    if (week.isSubmitted) {
      state = LogbookWeekState.submitted;
    } else if (end.isBefore(today)) {
      state = LogbookWeekState.missed;
    } else if (isCurrent && daysUntilDue <= 3) {
      state = LogbookWeekState.dueSoon;
    } else if (isCurrent) {
      state = LogbookWeekState.current;
    } else {
      state = LogbookWeekState.upcoming;
    }

    final info = LogbookWeekInfo(
      week: week,
      state: state,
      daysUntilDue: daysUntilDue,
      canSubmit: !week.isSubmitted && (isCurrent || end.isBefore(today)),
    );
    infos.add(info);
    if (isCurrent) currentInfo = info;
  }

  final lastEnd = sorted.isEmpty ? null : _dateOnly(sorted.last.weekEndDate);

  return LogbookSummary(
    totalWeeks: sorted.length,
    completedWeeks: sorted.where((week) => week.isSubmitted).length,
    missedWeeks: infos
        .where((info) => info.state == LogbookWeekState.missed)
        .length,
    currentWeek: currentWeek,
    current: currentInfo,
    isFinished: lastEnd != null && today.isAfter(lastEnd),
    weeks: infos,
  );
}
