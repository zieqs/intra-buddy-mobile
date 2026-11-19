import '../../../../core/errors/failures.dart';
import '../entities/enrollment.dart';

/// Reads the semesters a student is enrolled in, or the one open for signup.
abstract class EnrollmentRepository {
  /// The semester that applies to [userId] right now, or null when the account
  /// has no enrollment rows.
  Future<Result<Enrollment?>> currentFor(String userId, {DateTime? now});

  /// The semester the coordinator has opened for registration. Used before a
  /// student has an account, so it must not require a session.
  Future<Result<Enrollment?>> openSemester();
}
