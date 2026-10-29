import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/entities/logbook_week.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/repositories/logbook_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/providers/logbook_controller.dart';

class _FakeLogbookRepository implements LogbookRepository {
  _FakeLogbookRepository(this.items);

  List<LogbookWeek> items;
  bool failWrites = false;
  int loadCalls = 0;
  final List<(int, bool)> calls = [];

  @override
  Future<Result<List<LogbookWeek>>> loadWeeks() async {
    loadCalls++;
    return Right(items);
  }

  @override
  Future<Result<LogbookWeek>> toggleSubmitted(int id, bool submitted) async {
    calls.add((id, submitted));
    if (failWrites) return const Left(ServerFailure('offline'));

    final index = items.indexWhere((week) => week.id == id);
    final current = items[index];
    final updated = LogbookWeek(
      id: current.id,
      weekNumber: current.weekNumber,
      weekEndDate: current.weekEndDate,
      isSubmitted: submitted,
      submittedAt: submitted ? DateTime(2026, 10, 29) : null,
    );
    items = [...items]..[index] = updated;
    return Right(updated);
  }
}

LogbookWeek _week(int id, {bool submitted = false}) => LogbookWeek(
  id: id,
  weekNumber: id,
  weekEndDate: DateTime(2026, 9, 27).add(Duration(days: 7 * id)),
  isSubmitted: submitted,
);

void main() {
  late _FakeLogbookRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = _FakeLogbookRepository([_week(1), _week(2, submitted: true)]);
    container = ProviderContainer(
      overrides: [logbookRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(logbookControllerProvider.future);
  });

  test('marks a week as submitted', () async {
    final updated = await container
        .read(logbookControllerProvider.notifier)
        .toggleSubmitted(1, true);

    expect(updated, isTrue);
    expect(repo.calls, [(1, true)]);
    expect(
      container
          .read(logbookControllerProvider)
          .requireValue
          .firstWhere((w) => w.id == 1)
          .isSubmitted,
      isTrue,
    );
  });

  test('can undo a submission', () async {
    final updated = await container
        .read(logbookControllerProvider.notifier)
        .toggleSubmitted(2, false);

    expect(updated, isTrue);
    expect(
      container
          .read(logbookControllerProvider)
          .requireValue
          .firstWhere((w) => w.id == 2)
          .isSubmitted,
      isFalse,
    );
  });

  test(
    'rolls back and reports failure instead of replacing the list',
    () async {
      repo.failWrites = true;

      final updated = await container
          .read(logbookControllerProvider.notifier)
          .toggleSubmitted(1, true);

      expect(updated, isFalse);
      expect(container.read(logbookControllerProvider).hasError, isFalse);
      expect(
        container
            .read(logbookControllerProvider)
            .requireValue
            .firstWhere((w) => w.id == 1)
            .isSubmitted,
        isFalse,
      );
    },
  );

  test('does nothing when the week is already in that state', () async {
    final updated = await container
        .read(logbookControllerProvider.notifier)
        .toggleSubmitted(2, true);

    expect(updated, isTrue);
    expect(repo.calls, isEmpty);
  });
}
