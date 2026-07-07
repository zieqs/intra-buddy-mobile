import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class LogbookRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  LogbookRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

  Future<List<Map<String, dynamic>>> loadWeeks() async {
    final existing = await supabase
        .from('weekly_logbook_tracking')
        .select()
        .eq('student_id', _userId)
        .order('week_number', ascending: true);

    if (existing.isNotEmpty) return existing;

    final semester = await _getActiveSemester();
    if (semester == null) return [];

    final startDate = DateTime.parse(semester['start_date'] as String);
    final semesterId = semester['id'] as int;

    final rows = List.generate(14, (i) {
      final weekNumber = i + 1;
      return {
        'student_id': _userId,
        'semester_id': semesterId,
        'week_number': weekNumber,
        'week_end_date': startDate
            .add(Duration(days: 7 * weekNumber))
            .toIso8601String()
            .split('T')[0],
        'is_submitted': false,
      };
    });

    await supabase.from('weekly_logbook_tracking').insert(rows);

    return supabase
        .from('weekly_logbook_tracking')
        .select()
        .eq('student_id', _userId)
        .order('week_number', ascending: true);
  }

  Future<Map<String, dynamic>?> _getActiveSemester() async {
    final enrollment = await supabase
        .from('student_semesters')
        .select('semester_id')
        .eq('student_id', _userId)
        .maybeSingle();

    if (enrollment != null) {
      return supabase
          .from('semesters')
          .select()
          .eq('id', enrollment['semester_id'] as int)
          .single();
    }

    return supabase
        .from('semesters')
        .select()
        .eq('is_active', true)
        .maybeSingle();
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
