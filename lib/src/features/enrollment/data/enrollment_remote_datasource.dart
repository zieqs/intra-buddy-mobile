import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/enrollment.dart';
import '../domain/pick_current_enrollment.dart';

/// Maps a `semesters` row (or the `get_open_semester` RPC row) to an
/// [Enrollment].
Enrollment enrollmentFromRow(Map<String, dynamic> row) {
  return Enrollment(
    semesterId: row['id'] as int,
    name: row['name'] as String,
    startDate: DateTime.parse(row['start_date'] as String),
    endDate: DateTime.parse(row['end_date'] as String),
    isActive: row['is_active'] as bool? ?? false,
  );
}

class EnrollmentRemoteDataSource {
  EnrollmentRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  /// Resolves the semester the student should see right now.
  ///
  /// A student can have several enrollment rows; this reads all of them and
  /// lets [pickCurrentEnrollment] choose, so a second row never breaks the
  /// lookup.
  Future<Enrollment?> fetchCurrentEnrollment(
    String userId, {
    DateTime? now,
  }) async {
    final enrollments = await _supabase
        .from('student_semesters')
        .select('semester_id')
        .eq('student_id', userId);

    final semesterIds = enrollments
        .map((row) => row['semester_id'] as int)
        .toSet()
        .toList();
    if (semesterIds.isEmpty) return null;

    final semesters = await _supabase
        .from('semesters')
        .select('id, name, start_date, end_date, is_active')
        .inFilter('id', semesterIds);

    return pickCurrentEnrollment(
      semesters.map(enrollmentFromRow).toList(),
      now ?? DateTime.now(),
    );
  }

  /// The semester the coordinator has opened for new signups.
  ///
  /// This runs before the user is authenticated, so it goes through the
  /// `get_open_semester` RPC rather than reading the table directly.
  Future<Enrollment?> fetchOpenSemester() async {
    final response = await _supabase.rpc('get_open_semester');
    if (response is! List || response.isEmpty) return null;
    return enrollmentFromRow(Map<String, dynamic>.from(response.first as Map));
  }
}
