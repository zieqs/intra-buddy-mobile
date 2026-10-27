import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/features/jobs/domain/entities/job_application.dart';
import 'package:intra_buddy_mobile_v2/src/features/jobs/domain/repositories/job_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/jobs/presentation/providers/job_controller.dart';

class _FakeJobRepository implements JobRepository {
  bool failWrites = false;
  int addCalls = 0;
  int updateCalls = 0;
  final List<JobApplication> items = [];

  @override
  Future<Result<List<JobApplication>>> loadApplications() async => Right(items);

  @override
  Future<Result<JobApplication>> addApplication({
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    addCalls++;
    if (failWrites) return const Left(ServerFailure('offline'));
    return Right(
      JobApplication(
        id: 1,
        companyName: companyName,
        position: position,
        applicationDate: DateTime(2026, 1, 1),
        status: status,
        notes: notes,
      ),
    );
  }

  @override
  Future<Result<JobApplication>> updateApplication({
    required int id,
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    updateCalls++;
    if (failWrites) return const Left(ServerFailure('offline'));
    return Right(
      JobApplication(
        id: id,
        companyName: companyName,
        position: position,
        applicationDate: DateTime(2026, 1, 1),
        status: status,
        notes: notes,
      ),
    );
  }

  @override
  Future<Result<void>> deleteApplication(int id) async => const Right(null);
}

void main() {
  late _FakeJobRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = _FakeJobRepository();
    container = ProviderContainer(
      overrides: [jobRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(jobControllerProvider.future);
  });

  group('addApplication', () {
    test('reports success', () async {
      final saved = await container
          .read(jobControllerProvider.notifier)
          .addApplication(companyName: 'Acme', status: 'Pending');

      expect(saved, isTrue);
      expect(repo.addCalls, 1);
    });

    test(
      'reports failure so the form does not close on a lost write',
      () async {
        repo.failWrites = true;

        final saved = await container
            .read(jobControllerProvider.notifier)
            .addApplication(companyName: 'Acme', status: 'Pending');

        expect(saved, isFalse);
        // A failed save must not wipe the already-loaded list.
        expect(container.read(jobControllerProvider).hasError, isFalse);
        expect(container.read(jobControllerProvider).value, isNotNull);
      },
    );
  });

  group('updateApplication', () {
    test('reports success', () async {
      final saved = await container
          .read(jobControllerProvider.notifier)
          .updateApplication(id: 7, companyName: 'Acme', status: 'Interview');

      expect(saved, isTrue);
      expect(repo.updateCalls, 1);
    });

    test('reports failure', () async {
      repo.failWrites = true;

      final saved = await container
          .read(jobControllerProvider.notifier)
          .updateApplication(id: 7, companyName: 'Acme', status: 'Interview');

      expect(saved, isFalse);
    });
  });
}
