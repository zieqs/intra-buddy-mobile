import '../../checklist/domain/entities/checklist_item.dart';
import '../../logbook/domain/entities/logbook_week.dart';
import 'journey.dart';

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

JourneyChapterKind phaseFor(
  ChecklistItem item,
  DateTime? semesterStart,
  DateTime? semesterEnd,
) {
  switch (item.phase) {
    case 'before':
      return JourneyChapterKind.before;
    case 'during':
      return JourneyChapterKind.during;
    case 'after':
      return JourneyChapterKind.after;
  }

  final due = item.dueDate;
  if (due == null) return JourneyChapterKind.before;
  final dueDay = _day(due);
  if (semesterStart != null && dueDay.isBefore(_day(semesterStart))) {
    return JourneyChapterKind.before;
  }
  if (semesterEnd != null && dueDay.isAfter(_day(semesterEnd))) {
    return JourneyChapterKind.after;
  }
  return JourneyChapterKind.during;
}

Journey buildJourney({
  required List<ChecklistItem> checklist,
  required List<LogbookWeek> weeks,
  required DateTime? semesterStart,
  required DateTime? semesterEnd,
  String? semesterName,
  required DateTime now,
}) {
  final today = _day(now);
  final sortedWeeks = [...weeks]..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

  int? currentWeekNumber;
  for (final week in sortedWeeks) {
    if (!_day(week.weekEndDate).isBefore(today)) {
      currentWeekNumber = week.weekNumber;
      break;
    }
  }

  final before = <JourneyNode>[];
  final duringMilestones = <JourneyNode>[];
  final after = <JourneyNode>[];

  for (final item in checklist) {
    final chapter = phaseFor(item, semesterStart, semesterEnd);
    final due = item.dueDate;
    final overdue = !item.isCompleted &&
        due != null &&
        _day(due).isBefore(today);
    final locked = !item.isCompleted &&
        chapter == JourneyChapterKind.after &&
        semesterEnd != null &&
        today.isBefore(_day(semesterEnd));

    final state = item.isCompleted
        ? JourneyNodeState.done
        : overdue
        ? JourneyNodeState.missed
        : locked
        ? JourneyNodeState.locked
        : JourneyNodeState.open;

    final node = JourneyNode(
      id: 'milestone-${item.id}',
      kind: JourneyNodeKind.milestone,
      title: item.title,
      chapter: chapter,
      state: state,
      dueDate: due,
      sourceId: item.id,
      isCompleted: item.isCompleted,
      displayOrder: item.displayOrder,
    );

    switch (chapter) {
      case JourneyChapterKind.before:
        before.add(node);
      case JourneyChapterKind.during:
        duringMilestones.add(node);
      case JourneyChapterKind.after:
        after.add(node);
    }
  }

  final weekNodes = <JourneyNode>[];
  for (final week in sortedWeeks) {
    final end = _day(week.weekEndDate);
    final isCurrent = week.weekNumber == currentWeekNumber;
    final state = week.isSubmitted
        ? JourneyNodeState.done
        : end.isBefore(today)
        ? JourneyNodeState.missed
        : isCurrent
        ? JourneyNodeState.current
        : JourneyNodeState.open;

    weekNodes.add(
      JourneyNode(
        id: 'week-${week.weekNumber}',
        kind: JourneyNodeKind.week,
        title: 'Week ${week.weekNumber}',
        chapter: JourneyChapterKind.during,
        state: state,
        dueDate: week.weekEndDate,
        weekNumber: week.weekNumber,
        sourceId: week.id,
        isCompleted: week.isSubmitted,
        submittedAt: week.submittedAt,
      ),
    );
  }

  before.sort(_compareMilestones);
  after.sort(_compareMilestones);
  final during = [...weekNodes, ...duringMilestones]..sort(_compareDuring);

  final chapters = <JourneyChapter>[
    if (before.isNotEmpty)
      JourneyChapter(kind: JourneyChapterKind.before, nodes: before),
    if (during.isNotEmpty)
      JourneyChapter(kind: JourneyChapterKind.during, nodes: during),
    if (after.isNotEmpty)
      JourneyChapter(kind: JourneyChapterKind.after, nodes: after),
  ];

  JourneyNode? currentWeek;
  for (final node in weekNodes) {
    if (node.weekNumber == currentWeekNumber) {
      currentWeek = node;
      break;
    }
  }

  final total = chapters.fold<int>(0, (sum, chapter) => sum + chapter.total);
  final completed = chapters.fold<int>(
    0,
    (sum, chapter) => sum + chapter.completed,
  );

  return Journey(
    chapters: chapters,
    currentWeek: currentWeek,
    totalNodes: total,
    completedNodes: completed,
    semesterStart: semesterStart,
    semesterEnd: semesterEnd,
    semesterName: semesterName,
    anchorKind: _anchorKind(
      now: now,
      semesterStart: semesterStart,
      semesterEnd: semesterEnd,
      hasCurrentWeek: currentWeekNumber != null,
    ),
  );
}

int _compareMilestones(JourneyNode a, JourneyNode b) {
  final ad = a.dueDate;
  final bd = b.dueDate;
  if (ad == null && bd != null) return 1;
  if (ad != null && bd == null) return -1;
  if (ad != null && bd != null) {
    final compared = _day(ad).compareTo(_day(bd));
    if (compared != 0) return compared;
  }
  return a.displayOrder.compareTo(b.displayOrder);
}

int _compareDuring(JourneyNode a, JourneyNode b) {
  final ad = a.dueDate;
  final bd = b.dueDate;
  if (ad == null && bd != null) return 1;
  if (ad != null && bd == null) return -1;
  if (ad != null && bd != null) {
    final compared = _day(ad).compareTo(_day(bd));
    if (compared != 0) return compared;
  }
  if (a.kind != b.kind) {
    return a.kind == JourneyNodeKind.week ? -1 : 1;
  }
  final weekCompared = (a.weekNumber ?? 0).compareTo(b.weekNumber ?? 0);
  if (weekCompared != 0) return weekCompared;
  return a.displayOrder.compareTo(b.displayOrder);
}

JourneyChapterKind _anchorKind({
  required DateTime now,
  required DateTime? semesterStart,
  required DateTime? semesterEnd,
  required bool hasCurrentWeek,
}) {
  final today = _day(now);
  if (semesterStart != null && today.isBefore(_day(semesterStart))) {
    return JourneyChapterKind.before;
  }
  if (semesterEnd != null && today.isAfter(_day(semesterEnd))) {
    return JourneyChapterKind.after;
  }
  if (hasCurrentWeek) return JourneyChapterKind.during;
  if (semesterStart != null && semesterEnd != null) {
    return JourneyChapterKind.during;
  }
  return JourneyChapterKind.before;
}
