import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class JobRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  JobRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

  Future<List<Map<String, dynamic>>> loadApplications() async {
    final response = await supabase
        .from('job_applications')
        .select()
        .eq('student_id', _userId)
        .order('created_at', ascending: false);
    return response;
  }

  Future<Map<String, dynamic>> addApplication({
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    final response = await supabase
        .from('job_applications')
        .insert({
          'student_id': _userId,
          'company_name': companyName,
          'position': position,
          'application_date': DateTime.now().toIso8601String(),
          'status': status,
          'notes': notes,
        })
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateApplication({
    required int id,
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    final response = await supabase
        .from('job_applications')
        .update({
          'company_name': companyName,
          'position': position,
          'status': status,
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteApplication(int id) async {
    await supabase.from('job_applications').delete().eq('id', id);
  }
}
