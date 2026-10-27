import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/domain/entities/student_profile.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/presentation/providers/profile_controller.dart';

class _FakeProfileRepository implements ProfileRepository {
  bool failWrites = false;

  StudentProfile profile = const StudentProfile(
    id: 'u1',
    email: 'student@s.unikl.edu.my',
    fullName: 'Original Name',
    phoneNumber: '0123456789',
  );

  @override
  Future<Result<StudentProfile>> loadProfile() async => Right(profile);

  @override
  Future<Result<StudentProfile>> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    if (failWrites) return const Left(ServerFailure('offline'));
    profile = StudentProfile(
      id: profile.id,
      email: profile.email,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    return Right(profile);
  }
}

void main() {
  late _FakeProfileRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = _FakeProfileRepository();
    container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(profileControllerProvider.future);
  });

  test('updateProfile reports success', () async {
    final saved = await container
        .read(profileControllerProvider.notifier)
        .updateProfile(fullName: 'New Name');

    expect(saved, isTrue);
    expect(
      container.read(profileControllerProvider).value?.fullName,
      'New Name',
    );
  });

  test('updateProfile reports failure so the form stays open', () async {
    repo.failWrites = true;

    final saved = await container
        .read(profileControllerProvider.notifier)
        .updateProfile(fullName: 'New Name');

    expect(saved, isFalse);
    // A failed save must not replace the loaded profile with an error screen.
    expect(container.read(profileControllerProvider).hasError, isFalse);
    expect(
      container.read(profileControllerProvider).value?.fullName,
      'Original Name',
    );
  });
}
