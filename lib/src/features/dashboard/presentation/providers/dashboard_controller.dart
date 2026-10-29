import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';
import '../../../../core/providers/tab_index_provider.dart';
import '../journey_progress.dart';
import '../../../logbook/presentation/logbook_reminder_planner.dart';
import '../../../logbook/presentation/services/logbook_reminder_service.dart';

class DashboardData {
  final int totalMilestones;
  final int completedMilestones;
  final int jobApplications;
  final int documents;
  final DateTime? semesterStart;
  final DateTime? semesterEnd;
  final JourneyProgress journey;

  const DashboardData({
    required this.totalMilestones,
    required this.completedMilestones,
    required this.jobApplications,
    required this.documents,
    required this.semesterStart,
    required this.semesterEnd,
    required this.journey,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  ref.watch(dashboardRefreshProvider);
  ref.watch(currentTabIndexProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id;

  if (userId == null) {
    return DashboardData(
      totalMilestones: 0,
      completedMilestones: 0,
      jobApplications: 0,
      documents: 0,
      semesterStart: null,
      semesterEnd: null,
      journey: computeJourneyProgress(
        startDate: null,
        endDate: null,
        weeks: const [],
        now: DateTime.now(),
      ),
    );
  }

  Future<Map<String, dynamic>?> loadSemester() async {
    try {
      final enrollment = await supabase
          .from('student_semesters')
          .select('semester_id')
          .eq('student_id', userId)
          .maybeSingle();
      final semesterId = enrollment?['semester_id'];
      if (semesterId != null) {
        return await supabase
            .from('semesters')
            .select('start_date, end_date')
            .eq('id', semesterId)
            .maybeSingle();
      }
      return await supabase
          .from('semesters')
          .select('start_date, end_date')
          .eq('is_active', true)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  // The semester lookup runs alongside the aggregate queries.
  final semesterFuture = loadSemester();

  Future<int> count(String table, String column) async {
    final result = await supabase
        .from(table)
        .select(column)
        .eq('student_id', userId);
    return result.length;
  }

  // All five queries run at once instead of one after another.
  final (milestonesCount, completed, jobsCount, docsCount, weeks) = await (
    count('student_checklists', 'id'),
    supabase
        .from('student_checklists')
        .select('id')
        .eq('student_id', userId)
        .eq('is_completed', true),
    count('job_applications', 'id'),
    count('digital_wallet_items', 'id'),
    supabase
        .from('weekly_logbook_tracking')
        .select('week_number, week_end_date, is_submitted')
        .eq('student_id', userId)
        .order('week_number'),
  ).wait;

  final semester = await semesterFuture;
  final semesterStart = _parseDate(semester?['start_date']);
  final semesterEnd = _parseDate(semester?['end_date']);

  final journey = computeJourneyProgress(
    startDate: semesterStart,
    endDate: semesterEnd,
    weeks: weeks.map(_toJourneyWeek).toList(),
    now: DateTime.now(),
  );

  // Keep local logbook reminders in sync with the current deadlines.
  unawaited(
    LogbookReminderService.instance.reschedule(
      weeks.map(_toReminderWeek).toList(),
    ),
  );

  return DashboardData(
    totalMilestones: milestonesCount,
    completedMilestones: completed.length,
    jobApplications: jobsCount,
    documents: docsCount,
    semesterStart: semesterStart,
    semesterEnd: semesterEnd,
    journey: journey,
  );
});

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

JourneyWeek _toJourneyWeek(Map<String, dynamic> row) => JourneyWeek(
  weekNumber: (row['week_number'] as num).toInt(),
  endDate: DateTime.parse(row['week_end_date'] as String),
  isSubmitted: row['is_submitted'] == true,
);

ReminderWeek _toReminderWeek(Map<String, dynamic> row) => ReminderWeek(
  weekNumber: (row['week_number'] as num).toInt(),
  endDate: DateTime.parse(row['week_end_date'] as String),
  isSubmitted: row['is_submitted'] == true,
);
