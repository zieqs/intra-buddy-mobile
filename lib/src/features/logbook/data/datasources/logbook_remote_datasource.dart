import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class LogbookRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  LogbookRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

  Future<List<Map<String, dynamic>>> loadWeeks() async {
    return supabase
        .from('weekly_logbook_tracking')
        .select()
        .eq('student_id', _userId)
        .order('week_number', ascending: true);
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
