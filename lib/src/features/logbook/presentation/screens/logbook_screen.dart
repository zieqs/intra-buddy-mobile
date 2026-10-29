import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../logbook_week_info.dart';
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
              child: Padding(
                padding: const EdgeInsets.all(32),
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
                    const SizedBox(height: 8),
                    Text(
                      'Your weeks will appear once your INTRA semester is active.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: context.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          final summary = buildLogbookSummary(weeks, DateTime.now());

          return RefreshIndicator(
            onRefresh: () => ref.refresh(logbookControllerProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(summary: summary),
                const SizedBox(height: 16),
                ...summary.weeks.map((info) => _WeekCard(info: info)),
                const SizedBox(height: 8),
                Text(
                  'INTRA Buddy tracks your logbook status only. Submit the actual logbook through the INTRA portal.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.muted),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final LogbookSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final ratio = summary.totalWeeks == 0
        ? 0.0
        : summary.completedWeeks / summary.totalWeeks;
    final isComplete = summary.completedWeeks == summary.totalWeeks;

    final title = summary.currentWeek != null
        ? 'Week ${summary.currentWeek} of ${summary.totalWeeks}'
        : summary.isFinished
        ? 'Internship complete'
        : 'Logbook';

    final statusParts = <String>[];
    final current = summary.current;
    if (current != null && !current.week.isSubmitted) {
      statusParts.add(_dueLabel(current.daysUntilDue));
    }
    if (summary.missedWeeks > 0) {
      statusParts.add(
        '${summary.missedWeeks} ${summary.missedWeeks == 1 ? 'week' : 'weeks'} overdue',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${summary.completedWeeks} of ${summary.totalWeeks} weeks submitted',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.muted),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: context.outline,
                valueColor: AlwaysStoppedAnimation(
                  isComplete ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ),
            if (statusParts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                statusParts.join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: summary.missedWeeks > 0
                      ? AppColors.error
                      : AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends ConsumerWidget {
  final LogbookWeekInfo info;

  const _WeekCard({required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateColor = _stateColor(context);
    final highlighted =
        info.state == LogbookWeekState.current ||
        info.state == LogbookWeekState.dueSoon ||
        info.state == LogbookWeekState.missed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: highlighted ? stateColor : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: info.state == LogbookWeekState.upcoming
              ? context.outline
              : stateColor,
          child: info.state == LogbookWeekState.submitted
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
                  'W${info.week.weekNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: info.state == LogbookWeekState.upcoming
                        ? context.muted
                        : info.state == LogbookWeekState.dueSoon
                        ? AppColors.onTertiary
                        : Colors.white,
                  ),
                ),
        ),
        title: Text(
          'Week ${info.week.weekNumber}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          _subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: _subtitleColor(context)),
        ),
        trailing: _trailing(context, ref),
      ),
    );
  }

  Widget _trailing(BuildContext context, WidgetRef ref) {
    if (info.state == LogbookWeekState.submitted) {
      return IconButton(
        tooltip: 'Undo submission',
        icon: const Icon(Icons.undo, color: AppColors.primary),
        onPressed: () => _confirmToggle(context, ref, submitted: false),
      );
    }

    if (info.canSubmit) {
      return FilledButton.tonal(
        onPressed: () => _confirmToggle(context, ref, submitted: true),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text('Mark'),
      );
    }

    return Tooltip(
      message: 'Opens when the week starts',
      child: Icon(Icons.lock_clock, size: 20, color: context.muted),
    );
  }

  Future<void> _confirmToggle(
    BuildContext context,
    WidgetRef ref, {
    required bool submitted,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          submitted
              ? 'Mark Week ${info.week.weekNumber} as submitted?'
              : 'Undo Week ${info.week.weekNumber} submission?',
        ),
        content: Text(
          submitted
              ? "INTRA Buddy doesn't upload your logbook. Mark this after you've submitted it through the INTRA portal."
              : 'This will mark the week as not submitted. You can mark it again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(submitted ? 'Mark submitted' : 'Undo'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(logbookControllerProvider.notifier)
        .toggleSubmitted(info.week.id, submitted);
    if (!context.mounted) return;

    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not update the logbook. Please try again.'),
        ),
      );
    }
  }

  String get _subtitle {
    final date = _formatDate(info.week.weekEndDate);
    return switch (info.state) {
      LogbookWeekState.submitted =>
        'Submitted ${_formatDate(info.week.submittedAt ?? info.week.weekEndDate)}',
      LogbookWeekState.missed => 'Overdue · was due $date',
      LogbookWeekState.dueSoon =>
        '${_capitalise(_dueLabel(info.daysUntilDue))} · $date',
      LogbookWeekState.current => 'This week · due $date',
      LogbookWeekState.upcoming => 'Due $date',
    };
  }

  Color _subtitleColor(BuildContext context) => switch (info.state) {
    LogbookWeekState.missed => AppColors.error,
    LogbookWeekState.dueSoon => const Color(0xFFB45309),
    LogbookWeekState.current => AppColors.primary,
    _ => context.muted,
  };

  Color _stateColor(BuildContext context) => switch (info.state) {
    LogbookWeekState.submitted => AppColors.secondary,
    LogbookWeekState.missed => AppColors.error,
    LogbookWeekState.dueSoon => AppColors.tertiary,
    LogbookWeekState.current => AppColors.primary,
    LogbookWeekState.upcoming => context.outline,
  };
}

String _capitalise(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

String _dueLabel(int days) {
  if (days == 0) return 'due today';
  if (days == 1) return 'due tomorrow';
  if (days > 1) return 'due in $days days';
  if (days == -1) return '1 day overdue';
  return '${-days} days overdue';
}

String _formatDate(DateTime date) {
  const months = [
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
