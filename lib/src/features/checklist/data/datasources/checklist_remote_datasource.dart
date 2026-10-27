import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import 'checklist_merger.dart';

class ChecklistRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  ChecklistRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

  Future<List<Map<String, dynamic>>> loadChecklist() async {
    final semesterId = await _getActiveSemesterId();
    if (semesterId == null) return [];

    final templates = await supabase
        .from('checklist_templates')
        .select()
        .eq('semester_id', semesterId)
        .order('display_order', ascending: true);
    if (templates.isEmpty) return [];

    final templateIds = templates.map((t) => t['id'] as int).toList();

    // One query for every template the student already has.
    final existing = await supabase
        .from('student_checklists')
        .select()
        .eq('student_id', _userId)
        .inFilter('checklist_item_id', templateIds);

    final existingTemplateIds = existing
        .map((row) => row['checklist_item_id'])
        .toSet();
    final missing = templates
        .where((template) => !existingTemplateIds.contains(template['id']))
        .toList();

    // One batch insert instead of one insert per missing template.
    final List<Map<String, dynamic>> inserted;
    if (missing.isEmpty) {
      inserted = const [];
    } else {
      inserted = await supabase.from('student_checklists').insert([
        for (final template in missing)
          {
            'student_id': _userId,
            'checklist_item_id': template['id'],
            'is_completed': false,
          },
      ]).select();
    }

    return mergeChecklistRows(
      templates: templates,
      existing: existing,
      inserted: inserted,
    );
  }

  Future<void> toggleItem(int checklistId, bool completed) async {
    await supabase
        .from('student_checklists')
        .update({
          'is_completed': completed,
          if (completed) 'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', checklistId);
  }

  Future<int?> _getActiveSemesterId() async {
    final enrollment = await supabase
        .from('student_semesters')
        .select('semester_id')
        .eq('student_id', _userId)
        .maybeSingle();

    if (enrollment != null) return enrollment['semester_id'] as int;

    final activeSemester = await supabase
        .from('semesters')
        .select('id')
        .eq('is_active', true)
        .maybeSingle();

    if (activeSemester != null) return activeSemester['id'] as int;

    return null;
  }
}
