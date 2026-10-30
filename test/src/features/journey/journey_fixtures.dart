import 'package:intra_buddy_mobile_v2/src/features/checklist/domain/entities/checklist_item.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/entities/logbook_week.dart';

ChecklistItem journeyItem({
  int id = 1,
  String title = 'Milestone',
  String? phase,
  DateTime? due,
  bool done = false,
  int order = 0,
  bool required = true,
}) {
  return ChecklistItem(
    id: id,
    checklistItemId: id,
    title: title,
    isCompleted: done,
    isRequired: required,
    phase: phase,
    dueDate: due,
    displayOrder: order,
  );
}

LogbookWeek journeyWeek(
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
    submittedAt: submittedAt,
  );
}

JourneyNode journeyNode({
  String id = 'week-7',
  JourneyNodeKind kind = JourneyNodeKind.week,
  String title = 'Week 7',
  JourneyNodeState state = JourneyNodeState.current,
  JourneyChapterKind chapter = JourneyChapterKind.during,
  DateTime? due,
  int? weekNumber = 7,
  int? sourceId = 7,
  bool completed = false,
}) {
  return JourneyNode(
    id: id,
    kind: kind,
    title: title,
    chapter: chapter,
    state: state,
    dueDate: due,
    weekNumber: weekNumber,
    sourceId: sourceId,
    isCompleted: completed,
  );
}
