import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';

class DashboardData {
  final int totalMilestones;
  final int completedMilestones;
  final int jobApplications;
  final int documents;
  final int submittedWeeks;
  final int totalWeeks;
  final int unreadNotifications;

  const DashboardData({
    required this.totalMilestones,
    required this.completedMilestones,
    required this.jobApplications,
    required this.documents,
    required this.submittedWeeks,
    required this.totalWeeks,
    required this.unreadNotifications,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id;

  if (userId == null) {
    return const DashboardData(
      totalMilestones: 0,
      completedMilestones: 0,
      jobApplications: 0,
      documents: 0,
      submittedWeeks: 0,
      totalWeeks: 0,
      unreadNotifications: 0,
    );
  }

  Future<int> count(String table, String column) async {
    final result = await supabase
        .from(table)
        .select(column)
        .eq('student_id', userId);
    return result.length;
  }

  final milestonesCount = await count('student_checklists', 'id');
  final completedCount = await supabase
      .from('student_checklists')
      .select('id')
      .eq('student_id', userId)
      .eq('is_completed', true);

  final jobsCount = await count('job_applications', 'id');
  final docsCount = await count('digital_wallet_items', 'id');

  final weeks = await supabase
      .from('weekly_logbook_tracking')
      .select('is_submitted')
      .eq('student_id', userId);

  final submittedWeeks = weeks.where((w) => w['is_submitted'] == true).length;

  final unread = await supabase
      .from('notifications')
      .select('id')
      .eq('recipient_id', userId)
      .eq('is_read', false);

  return DashboardData(
    totalMilestones: milestonesCount,
    completedMilestones: completedCount.length,
    jobApplications: jobsCount,
    documents: docsCount,
    submittedWeeks: submittedWeeks,
    totalWeeks: weeks.length,
    unreadNotifications: unread.length,
  );
});
