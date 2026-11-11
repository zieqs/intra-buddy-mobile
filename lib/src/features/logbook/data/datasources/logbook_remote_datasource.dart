import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../enrollment/data/enrollment_remote_datasource.dart';
import '../../../enrollment/domain/entities/enrollment.dart';

class LogbookRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  LogbookRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

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

  Future<Enrollment?> _currentSemester() {
    return resolveCurrentEnrollment(supabase, _userId);
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
