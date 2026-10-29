import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../journey_progress.dart';

class JourneyCard extends StatelessWidget {
  final JourneyProgress progress;
  final DateTime? semesterStart;
  final DateTime? semesterEnd;
  final int milestonesDone;
  final int milestonesTotal;
  final VoidCallback onChecklist;
  final VoidCallback onLogbook;

  const JourneyCard({
    super.key,
    required this.progress,
    required this.semesterStart,
    required this.semesterEnd,
    required this.milestonesDone,
    required this.milestonesTotal,
    required this.onChecklist,
    required this.onLogbook,
  });

  @override
  Widget build(BuildContext context) {
    final milestonesRatio = milestonesTotal == 0
        ? 0.0
        : milestonesDone / milestonesTotal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your INTRA Journey',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _stage(
              context,
              icon: Icons.flag_outlined,
              title: 'Preparation',
              subtitle: _milestonesSubtitle,
              onTap: onChecklist,
            ),
            if (milestonesTotal > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: milestonesRatio,
                  minHeight: 6,
                  backgroundColor: context.outline,
                  color: AppColors.secondary,
                ),
              ),
            ],
            _connector(context),
            _internshipStage(context),
          ],
        ),
      ),
    );
  }

  String get _milestonesSubtitle {
    if (milestonesTotal == 0) return 'No milestones yet';
    if (milestonesDone == milestonesTotal) {
      return '$milestonesDone of $milestonesTotal milestones · complete';
    }
    return '$milestonesDone of $milestonesTotal milestones';
  }

  Widget _connector(BuildContext context) {
    final label = semesterStart != null && semesterEnd != null
        ? '${_shortDate(semesterStart!)} – ${_shortDate(semesterEnd!)}'
        : semesterStart != null
        ? 'Starts ${_shortDate(semesterStart!)}'
        : null;

    return Row(
      children: [
        Container(
          width: 2,
          height: 24,
          margin: const EdgeInsets.only(left: 15),
          color: context.outline,
        ),
        const SizedBox(width: 12),
        if (label != null)
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.muted),
          ),
      ],
    );
  }

  Widget _internshipStage(BuildContext context) {
    final p = progress;
    final hasWeeks = p.totalWeeks > 0;

    final title = switch (p.phase) {
      JourneyPhase.notStarted => 'Internship',
      JourneyPhase.finished => 'Journey complete',
      JourneyPhase.inProgress =>
        p.currentWeek != null
            ? 'Week ${p.currentWeek} of ${p.totalWeeks}'
            : 'Internship',
    };

    final subtitle = switch (p.phase) {
      JourneyPhase.notStarted =>
        semesterStart != null
            ? 'Starts ${_shortDate(semesterStart!)} · ${p.totalWeeks} weeks'
            : '${p.totalWeeks} weeks',
      JourneyPhase.finished => _counts(p),
      JourneyPhase.inProgress =>
        hasWeeks ? _counts(p) : 'Logbook not set up yet',
    };

    return InkWell(
      onTap: onLogbook,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stage(
              context,
              icon: Icons.calendar_month_outlined,
              title: title,
              subtitle: subtitle,
              onTap: null,
              trailing: Icon(Icons.chevron_right, color: context.muted),
            ),
            if (hasWeeks) ...[
              const SizedBox(height: 12),
              _weekStrip(context),
              if (p.phase == JourneyPhase.inProgress) ...[
                const SizedBox(height: 12),
                if (p.nextWeekNumber != null && p.nextDeadline != null)
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: context.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Week ${p.nextWeekNumber} ends ${_shortDate(p.nextDeadline!)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: context.muted),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'All weeks submitted',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _stage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primaryContainer,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.muted),
                ),
              ],
            ),
          ),
          trailing ?? Icon(Icons.chevron_right, color: context.muted),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }

  Widget _weekStrip(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < progress.weekStates.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: _weekColor(context, progress.weekStates[i]),
                borderRadius: BorderRadius.circular(3),
                border: progress.weekStates[i].current
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _weekColor(BuildContext context, JourneyWeekStatus status) {
    if (status.submitted) return AppColors.secondary;
    if (status.missed) return AppColors.error;
    if (status.current) return AppColors.primary;
    return context.outline;
  }

  String _counts(JourneyProgress p) {
    final parts = <String>['${p.completedWeeks} done'];
    if (p.missedWeeks > 0) parts.add('${p.missedWeeks} missed');
    parts.add('${p.remainingWeeks} to go');
    return parts.join(' · ');
  }

  String _shortDate(DateTime date) {
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
}
