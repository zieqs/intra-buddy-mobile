import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../notifications/presentation/providers/notification_controller.dart';
import '../../../notifications/presentation/widgets/latest_notification_banner.dart';
import '../providers/dashboard_controller.dart';
import '../widgets/journey_card.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.watch(authControllerProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    final notificationsAsync = ref.watch(notificationControllerProvider);
    final notifications = notificationsAsync.value;
    final latest = notifications == null || notifications.isEmpty
        ? null
        : notifications.first;
    final unread = ref.watch(unreadNotificationCountProvider);
    final hasLoadedNotifications = notificationsAsync.hasValue;
    final imageUrl = latest != null && latest.imagePaths.isNotEmpty
        ? ref
              .watch(supabaseClientProvider)
              .storage
              .from('broadcast-media')
              .getPublicUrl(latest.imagePaths.first)
        : null;

    final userName = authCtrl.value?.fullName ?? 'Student';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(notificationControllerProvider);
        await Future.wait([
          ref.refresh(dashboardProvider.future),
          ref.read(notificationControllerProvider.future),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $userName!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lets track your internship progress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: context.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          LatestNotificationBanner(
            notification: latest,
            unreadCount: unread,
            imageUrl: imageUrl,
            isLoading: !hasLoadedNotifications && notificationsAsync.isLoading,
            hasError: !hasLoadedNotifications && notificationsAsync.hasError,
            onTap: () => context.push('/notifications'),
          ),
          const SizedBox(height: 16),
          dashboardAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Failed to load dashboard data'),
              ),
            ),
            data: (data) => Column(
              children: [
                JourneyCard(
                  progress: data.journey,
                  semesterStart: data.semesterStart,
                  semesterEnd: data.semesterEnd,
                  milestonesDone: data.completedMilestones,
                  milestonesTotal: data.totalMilestones,
                  onChecklist: () => context.go('/checklist'),
                  onLogbook: () => context.push('/logbook'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Job Applications',
                        value: '${data.jobApplications}',
                        color: context.secondaryContainer,
                        onTap: () => context.go('/jobs'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Documents',
                        value: '${data.documents}',
                        color: context.tertiaryContainer,
                        onTap: () => context.go('/my-documents'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(alpha: 0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
