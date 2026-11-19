import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/data/enrollment_remote_datasource.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/data/repositories/enrollment_repository_impl.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/domain/entities/enrollment.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements EnrollmentRemoteDataSource {}

final _semester = Enrollment(
  semesterId: 1,
  name: 'INTRA Session 1 2026/2027',
  startDate: DateTime(2026, 11, 1),
  endDate: DateTime(2027, 2, 7),
);

void main() {
  late _MockDataSource dataSource;
  late EnrollmentRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = EnrollmentRepositoryImpl(dataSource);
  });

  group('currentFor', () {
    test('returns the enrollment resolved by the datasource', () async {
      when(
        () => dataSource.fetchCurrentEnrollment(
          'student-1',
          now: any(named: 'now'),
        ),
      ).thenAnswer((_) async => _semester);

      final result = await repository.currentFor('student-1');

      result.fold(
        (failure) => fail(failure.message),
        (enrollment) => expect(enrollment, same(_semester)),
      );
    });

    test('returns null when the student has no enrollment', () async {
      when(
        () => dataSource.fetchCurrentEnrollment(any(), now: any(named: 'now')),
      ).thenAnswer((_) async => null);

      final result = await repository.currentFor('student-1');

      result.fold(
        (failure) => fail(failure.message),
        (enrollment) => expect(enrollment, isNull),
      );
    });

    test('turns a datasource error into a failure', () async {
      when(
        () => dataSource.fetchCurrentEnrollment(any(), now: any(named: 'now')),
      ).thenThrow(Exception('offline'));

      final result = await repository.currentFor('student-1');

      result.fold(
        (failure) => expect(failure.message, contains('offline')),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('openSemester', () {
    test('returns the semester open for registration', () async {
      when(
        () => dataSource.fetchOpenSemester(),
      ).thenAnswer((_) async => _semester);

      final result = await repository.openSemester();

      result.fold(
        (failure) => fail(failure.message),
        (enrollment) => expect(enrollment, same(_semester)),
      );
    });

    test('turns a datasource error into a failure', () async {
      when(
        () => dataSource.fetchOpenSemester(),
      ).thenThrow(Exception('offline'));

      final result = await repository.openSemester();

      expect(result.isLeft(), isTrue);
    });
  });
}
