import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/logbook_week.dart';
import '../providers/logbook_controller.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(logbookControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logbookState = ref.watch(logbookControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Logbook')),
      body: logbookState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load logbook',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(logbookControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (weeks) {
          if (weeks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: context.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No logbook entries yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final submitted = weeks.where((w) => w.isSubmitted).length;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(logbookControllerProvider.future),
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
                          'Submission Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: weeks.isEmpty ? 0 : submitted / weeks.length,
                            minHeight: 8,
                            backgroundColor: context.outline,
                            valueColor: AlwaysStoppedAnimation(
                              submitted == weeks.length
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$submitted / ${weeks.length} weeks submitted',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: context.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...weeks.map((week) => _WeekCard(week: week)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeekCard extends ConsumerWidget {
  final LogbookWeek week;

  const _WeekCard({required this.week});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: week.isSubmitted
              ? AppColors.secondary
              : context.outline,
          child: week.isSubmitted
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
                  'W${week.weekNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.muted,
                  ),
                ),
        ),
        title: Text(
          'Week ${week.weekNumber}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          'Ending ${_formatDate(week.weekEndDate)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.muted),
        ),
        trailing: week.isSubmitted
            ? const Icon(Icons.check_circle, color: AppColors.secondary)
            : ElevatedButton(
                onPressed: () {
                  ref
                      .read(logbookControllerProvider.notifier)
                      .toggleSubmitted(week.id, true);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Submit'),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
