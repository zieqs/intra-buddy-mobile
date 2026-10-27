import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/data/datasources/checklist_merger.dart';

Map<String, dynamic> _template(int id, {bool? required, String? title}) => {
  'id': id,
  'title': title ?? 'Template $id',
  'description': 'Description $id',
  'required': required,
  'display_order': id,
};

Map<String, dynamic> _row(
  int id,
  int templateId, {
  bool isCompleted = false,
  String? completedAt,
}) => {
  'id': id,
  'checklist_item_id': templateId,
  'is_completed': isCompleted,
  'completed_at': completedAt,
};

void main() {
  test('returns rows in template order even when data arrives unordered', () {
    final rows = mergeChecklistRows(
      templates: [_template(3), _template(1), _template(2)],
      existing: [_row(101, 1), _row(102, 2), _row(103, 3)],
      inserted: const [],
    );

    expect(rows.map((r) => r['checklist_item_id']), [3, 1, 2]);
  });

  test('carries completion state from existing rows', () {
    final rows = mergeChecklistRows(
      templates: [_template(1)],
      existing: [
        _row(101, 1, isCompleted: true, completedAt: '2026-10-01T00:00:00Z'),
      ],
      inserted: const [],
    );

    expect(rows.single['is_completed'], isTrue);
    expect(rows.single['completed_at'], '2026-10-01T00:00:00Z');
    expect(rows.single['id'], 101);
  });

  test('uses freshly inserted rows for templates that had none', () {
    final rows = mergeChecklistRows(
      templates: [_template(1), _template(2)],
      existing: [_row(101, 1)],
      inserted: [_row(202, 2)],
    );

    expect(rows.length, 2);
    expect(rows.firstWhere((r) => r['checklist_item_id'] == 2)['id'], 202);
  });

  test('defaults required to true when the template does not specify it', () {
    final rows = mergeChecklistRows(
      templates: [_template(1, required: null)],
      existing: [_row(101, 1)],
      inserted: const [],
    );

    expect(rows.single['is_required'], isTrue);
  });

  test(
    'skips templates with no matching row instead of emitting a null id',
    () {
      final rows = mergeChecklistRows(
        templates: [_template(1), _template(2)],
        existing: [_row(101, 1)],
        inserted: const [],
      );

      expect(rows.length, 1);
      expect(rows.single['id'], 101);
    },
  );
}
