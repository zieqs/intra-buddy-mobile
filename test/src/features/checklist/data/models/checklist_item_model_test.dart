import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/data/models/checklist_item_model.dart';

void main() {
  test('maps phase and due_date', () {
    final model = ChecklistItemModel.fromJson({
      'id': 1,
      'checklist_item_id': 2,
      'title': 'Final report',
      'description': null,
      'is_completed': false,
      'is_required': true,
      'completed_at': null,
      'display_order': 9,
      'phase': 'after',
      'due_date': '2027-01-20',
    });

    expect(model.phase, 'after');
    expect(model.dueDate, DateTime(2027, 1, 20));
    expect(model.toEntity().phase, 'after');
    expect(model.toEntity().dueDate, DateTime(2027, 1, 20));
  });
}
