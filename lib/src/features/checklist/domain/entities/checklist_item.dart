class ChecklistItem {
  final int id;
  final int checklistItemId;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isRequired;
  final DateTime? completedAt;
  final String? phase;
  final DateTime? dueDate;
  final int displayOrder;

  const ChecklistItem({
    required this.id,
    required this.checklistItemId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.isRequired = true,
    this.completedAt,
    this.phase,
    this.dueDate,
    required this.displayOrder,
  });
}
