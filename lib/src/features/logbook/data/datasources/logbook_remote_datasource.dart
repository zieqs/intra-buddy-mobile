import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../enrollment/domain/entities/enrollment.dart';
import '../../../enrollment/domain/repositories/enrollment_repository.dart';

class LogbookRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;
  final EnrollmentRepository enrollmentRepository;

  LogbookRemoteDataSource(
    this.authService,
    this.supabase,
    this.enrollmentRepository,
  );

  String get _userId => authService.requireUserId();

  Future<List<Map<String, dynamic>>> loadWeeks() async {
    final semester = await _currentSemester();
    if (semester == null) return [];

    final existing = await _weeksFor(semester.semesterId);
    if (existing.isNotEmpty) return existing;

    final rows = List.generate(14, (i) {
      final weekNumber = i + 1;
      return {
        'student_id': _userId,
        'semester_id': semester.semesterId,
        'week_number': weekNumber,
        'week_end_date': semester.startDate
            .add(Duration(days: 7 * weekNumber))
            .toIso8601String()
            .split('T')[0],
        'is_submitted': false,
      };
    });

    await supabase.from('weekly_logbook_tracking').insert(rows);

    return _weeksFor(semester.semesterId);
  }

  /// Read-only: never seeds rows. Used by the journey trail.
  Future<List<Map<String, dynamic>>> loadExistingWeeks() async {
    final semester = await _currentSemester();
    if (semester == null) return [];
    return _weeksFor(semester.semesterId);
  }

  Future<List<Map<String, dynamic>>> _weeksFor(int semesterId) {
    return supabase
        .from('weekly_logbook_tracking')
        .select()
        .eq('student_id', _userId)
        .eq('semester_id', semesterId)
        .order('week_number', ascending: true);
  }

  Future<Enrollment?> _currentSemester() async {
    final result = await enrollmentRepository.currentFor(_userId);
    return result.fold((failure) => throw failure, (enrollment) => enrollment);
  }

  Future<void> toggleSubmitted(int id, bool submitted) async {
    await supabase
        .from('weekly_logbook_tracking')
        .update({
          'is_submitted': submitted,
          if (submitted) 'submitted_at': DateTime.now().toIso8601String(),
          if (!submitted) 'submitted_at': null,
        })
        .eq('id', id);
  }
}
