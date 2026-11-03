import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/domain/entities/checklist_item.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/presentation/providers/checklist_controller.dart';

class _FakeChecklistRepository implements ChecklistRepository {
  @override
  Future<Result<List<ChecklistItem>>> loadChecklist() async => Right([
    ChecklistItem(
      id: 1,
      checklistItemId: 7,
      title: 'Submit INTRA Official Forms',
      isCompleted: true,
      isRequired: true,
      completedAt: DateTime(2026, 10, 30),
      displayOrder: 0,
    ),
  ]);

  @override
  Future<Result<ChecklistItem>> toggleItem(
    int checklistId,
    bool completed,
  ) async => Right(
    ChecklistItem(
      id: checklistId,
      checklistItemId: 7,
      title: 'Submit INTRA Official Forms',
      isCompleted: completed,
      isRequired: true,
      displayOrder: 0,
    ),
  );
}

void main() {
  test('undoing a milestone clears its completion time', () async {
    final container = ProviderContainer(
      overrides: [
        checklistRepositoryProvider.overrideWithValue(
          _FakeChecklistRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(checklistControllerProvider.future);
    await container
        .read(checklistControllerProvider.notifier)
        .toggleItem(1, false);

    final item = container.read(checklistControllerProvider).value!.single;
    expect(item.isCompleted, isFalse);
    expect(item.completedAt, isNull);
  });
}
