import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/dashboard_controller.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.watch(authControllerProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    final userName = authCtrl.value?.fullName ?? 'Student';

    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider.future),
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
                    'Track your internship progress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
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
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Milestones',
                        value:
                            '${data.completedMilestones}/${data.totalMilestones}',
                        color: AppColors.primaryContainer,
                        onTap: () => context.go('/checklist'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Applications',
                        value: '${data.jobApplications}',
                        color: AppColors.secondaryContainer,
                        onTap: () => context.go('/jobs'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Documents',
                        value: '${data.documents}',
                        color: AppColors.tertiaryContainer,
                        onTap: () => context.go('/my-documents'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Logbook',
                        value: data.totalWeeks > 0
                            ? '${(data.submittedWeeks / data.totalWeeks * 100).round()}%'
                            : '0%',
                        color: AppColors.errorContainer,
                        onTap: () => context.push('/logbook'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/notifications'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (data.unreadNotifications > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${data.unreadNotifications}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
