/// Combines checklist templates with the student's own checklist rows.
///
/// Rows for templates the student does not have yet are passed in [inserted]
/// (created in a single batch by the caller). Output keeps the template order
/// and never emits a row without an id.
List<Map<String, dynamic>> mergeChecklistRows({
  required List<Map<String, dynamic>> templates,
  required List<Map<String, dynamic>> existing,
  required List<Map<String, dynamic>> inserted,
}) {
  final byTemplateId = <int, Map<String, dynamic>>{};
  for (final row in [...existing, ...inserted]) {
    final templateId = row['checklist_item_id'];
    if (templateId is int) byTemplateId[templateId] = row;
  }

  final rows = <Map<String, dynamic>>[];
  for (final template in templates) {
    final templateId = template['id'];
    if (templateId is! int) continue;

    final row = byTemplateId[templateId];
    if (row == null) continue;

    rows.add({
      'id': row['id'],
      'checklist_item_id': templateId,
      'title': template['title'],
      'description': template['description'],
      'is_completed': row['is_completed'] ?? false,
      'is_required': template['required'] ?? true,
      'completed_at': row['completed_at'],
      'display_order': template['display_order'],
    });
  }

  return rows;
}
