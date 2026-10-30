import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../logbook_week_info.dart';

class LogbookView extends StatelessWidget {
  const LogbookView({
    super.key,
    required this.summary,
    required this.streak,
    required this.userName,
    required this.bell,
    required this.onProfile,
    required this.onWeekTap,
    required this.onRefresh,
  });

  final LogbookSummary summary;
  final int streak;
  final String userName;
  final Widget bell;
  final VoidCallback onProfile;
  final ValueChanged<LogbookWeekInfo> onWeekTap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final current = summary.current;
    final others = summary.weeks
        .where((info) => info.week.weekNumber != summary.currentWeek)
        .toList();
    final overdue = summary.missedWeeks;

    return BuddyScaffold(
      topBar: BuddyTopBar(
        brand: 'LOGBOOK',
        streak: streak,
        userName: userName,
        bell: bell,
        onProfile: onProfile,
      ),
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOGBOOK',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: context.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.currentWeek != null
                      ? 'Week ${summary.currentWeek}.'
                      : summary.isFinished
                      ? 'Journey complete.'
                      : 'Logbook.',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: context.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${summary.completedWeeks} of ${summary.totalWeeks} submitted'
                  '${overdue > 0 ? ' · $overdue overdue' : ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: context.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: summary.totalWeeks == 0
                        ? 0
                        : summary.completedWeeks / summary.totalWeeks,
                    minHeight: 8,
                    color: context.blue,
                    backgroundColor: context.line,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (current != null)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: _ThisWeekCard(
                info: current,
                onTap: () => onWeekTap(current),
              ),
            ),
          ),
        if (current != null)
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ALL WEEKS',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: context.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (others.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Text(
                      'No other weeks yet.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.muted,
                      ),
                    ),
                  )
                else
                  for (final info in others)
                    _WeekRow(info: info, onTap: () => onWeekTap(info)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              'INTRA Buddy tracks your logbook status only. Submit the actual logbook through the INTRA portal.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.muted),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThisWeekCard extends StatelessWidget {
  const _ThisWeekCard({required this.info, required this.onTap});

  final LogbookWeekInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final submitted = info.week.isSubmitted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: context.line, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'THIS WEEK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.sunText,
                  ),
                ),
              ),
              Text(
                _statusLabel(info),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: submitted ? context.blue : context.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Week ${info.week.weekNumber}',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: context.ink),
          ),
          const SizedBox(height: 2),
          Text(
            _subtitle(info),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: submitted ? 'Undo submission' : 'Mark submitted',
            onPressed: submitted || info.canSubmit ? onTap : null,
          ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.info, required this.onTap});

  final LogbookWeekInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final submitted = info.week.isSubmitted;
    final missed = info.state == LogbookWeekState.missed;
    final current = info.state == LogbookWeekState.current ||
        info.state == LogbookWeekState.dueSoon;
    final interactive = submitted || info.canSubmit;

    final background = submitted
        ? context.blue
        : current
        ? context.sun
        : missed
        ? context.alert
        : context.card;
    final foreground = submitted || missed
        ? AppColors.white
        : current
        ? context.sunText
        : context.muted;

    return InkWell(
      onTap: interactive ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background,
                border: Border.all(
                  color: current || missed ? background : context.line,
                  width: 1.5,
                ),
              ),
              child: submitted
                  ? const Icon(Icons.check_rounded, size: 20, color: AppColors.white)
                  : missed
                  ? const Icon(
                      Icons.priority_high_rounded,
                      size: 20,
                      color: AppColors.white,
                    )
                  : Text(
                      '${info.week.weekNumber}',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week ${info.week.weekNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(info),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: missed ? context.alert : context.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatusTag(label: _statusLabel(info), info: info),
          ],
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label, required this.info});

  final String label;
  final LogbookWeekInfo info;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (info.state) {
      LogbookWeekState.submitted => (context.blue, AppColors.white),
      LogbookWeekState.missed => (context.alert, AppColors.white),
      LogbookWeekState.current ||
      LogbookWeekState.dueSoon => (context.sun, context.sunText),
      LogbookWeekState.upcoming => (context.ice, context.muted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.node),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: foreground,
        ),
      ),
    );
  }
}

String _statusLabel(LogbookWeekInfo info) {
  return switch (info.state) {
    LogbookWeekState.submitted => 'Submitted',
    LogbookWeekState.missed => 'Overdue',
    LogbookWeekState.dueSoon => info.daysUntilDue == 0
        ? 'Due today'
        : info.daysUntilDue == 1
        ? 'Due tomorrow'
        : 'Due in ${info.daysUntilDue}d',
    LogbookWeekState.current => 'This week',
    LogbookWeekState.upcoming => 'Upcoming',
  };
}

String _subtitle(LogbookWeekInfo info) {
  final date = _formatDate(info.week.weekEndDate);
  return switch (info.state) {
    LogbookWeekState.submitted =>
      'Submitted ${_formatDate(info.week.submittedAt ?? info.week.weekEndDate)}',
    LogbookWeekState.missed => 'Was due $date',
    LogbookWeekState.dueSoon || LogbookWeekState.current => 'Due $date',
    LogbookWeekState.upcoming => 'Due $date',
  };
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
  return '${date.day} ${months[date.month - 1]}';
}
