import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';
import '../../../checklist/presentation/providers/checklist_controller.dart';
import '../../../logbook/presentation/providers/logbook_controller.dart';
import '../../domain/build_journey.dart';
import '../../domain/journey.dart';

class SemesterInfo {
  const SemesterInfo({this.name, this.start, this.end});

  final String? name;
  final DateTime? start;
  final DateTime? end;
}

final journeyProvider = FutureProvider<Journey>((ref) async {
  ref.watch(dashboardRefreshProvider);

  final auth = ref.watch(authServiceProvider);
  final userId = auth.currentUser?.id;
  if (userId == null) return Journey.empty();

  final supabase = ref.watch(supabaseClientProvider);
  final checklistRepo = ref.watch(checklistRepositoryProvider);
  final logbookRepo = ref.watch(logbookRepositoryProvider);

  final semester = await _loadSemester(supabase, userId);
  final checklistResult = await checklistRepo.loadChecklist();
  final weeksResult = await logbookRepo.loadExistingWeeks();

  final checklist = checklistResult.fold((failure) => throw failure, (v) => v);
  final weeks = weeksResult.fold((failure) => throw failure, (v) => v);

  return buildJourney(
    checklist: checklist,
    weeks: weeks,
    semesterStart: semester.start,
    semesterEnd: semester.end,
    semesterName: semester.name,
    now: DateTime.now(),
  );
});

Future<SemesterInfo> _loadSemester(
  SupabaseClient supabase,
  String userId,
) async {
  try {
    final enrollment = await supabase
        .from('student_semesters')
        .select('semester_id')
        .eq('student_id', userId)
        .maybeSingle();

    final semesterId = enrollment?['semester_id'];
    final response = semesterId != null
        ? await supabase
              .from('semesters')
              .select('name, start_date, end_date')
              .eq('id', semesterId as int)
              .maybeSingle()
        : await supabase
              .from('semesters')
              .select('name, start_date, end_date')
              .eq('is_active', true)
              .maybeSingle();

    if (response == null) return const SemesterInfo();
    return SemesterInfo(
      name: response['name'] as String?,
      start: _parseDate(response['start_date']),
      end: _parseDate(response['end_date']),
    );
  } catch (_) {
    return const SemesterInfo();
  }
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
