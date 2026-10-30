import 'package:intra_buddy_mobile_v2/src/features/checklist/domain/entities/checklist_item.dart';
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
