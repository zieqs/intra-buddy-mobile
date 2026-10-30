import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../domain/entities/job_application.dart';

class JobsView extends StatelessWidget {
  const JobsView({
    super.key,
    required this.items,
    required this.streak,
    required this.userName,
    required this.bell,
    required this.onProfile,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    this.onStreakTap,
  });

  final List<JobApplication> items;
  final int streak;
  final String userName;
  final Widget bell;
  final VoidCallback onProfile;
  final VoidCallback onAdd;
  final ValueChanged<JobApplication> onEdit;
  final ValueChanged<JobApplication> onDelete;
  final Future<void> Function() onRefresh;
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    final topBar = BuddyTopBar(
      brand: 'JOBS',
      streak: streak,
      userName: userName,
      bell: bell,
      onProfile: onProfile,
      onStreakTap: onStreakTap,
    );

    if (items.isEmpty) {
      return BuddyScaffold(
        topBar: topBar,
        onRefresh: onRefresh,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              headline: 'Your next move.',
              body: 'No applications yet. Add the first one to start tracking.',
              actionLabel: 'Add application',
              onAction: onAdd,
            ),
          ),
        ],
      );
    }

    final applied = items.where((item) => item.status == 'Pending').length;
    final interview = items.where((item) => item.status == 'Interview').length;
    final offers = items
        .where((item) => item.status == 'Offer' || item.status == 'Accepted')
        .length;
    final inPlay = items.where((item) => item.status != 'Rejected').length;

    return BuddyScaffold(
      topBar: topBar,
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
                  'APPLICATIONS',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: context.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  inPlay == 0 ? 'All quiet.' : '$inPlay in play.',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: context.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${items.length} tracked · $offers '
                  '${offers == 1 ? 'offer' : 'offers'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: context.muted),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: context.line, width: 1.5),
              ),
              child: Row(
                children: [
                  _PipelineCell(value: applied, label: 'Applied'),
                  _divider(context),
                  _PipelineCell(value: interview, label: 'Interview'),
                  _divider(context),
                  _PipelineCell(value: offers, label: 'Offer'),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: PrimaryButton(
              label: 'Add application',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ALL APPLICATIONS',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: context.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final item in items)
                  _JobRow(
                    item: item,
                    onEdit: () => onEdit(item),
                    onDelete: () => onDelete(item),
                  ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
    width: 1,
    height: 30,
    color: context.line,
  );
}

class _PipelineCell extends StatelessWidget {
  const _PipelineCell({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: context.blue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final JobApplication item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tone = switch (item.status) {
      'Interview' => StatusTone.accent,
      'Offer' || 'Accepted' => StatusTone.sun,
      'Rejected' => StatusTone.alert,
      _ => StatusTone.neutral,
    };

    return InkWell(
      onTap: onEdit,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.position ?? 'Application',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Applied ${_formatDate(item.applicationDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusChip(label: item.status, tone: tone),
                const SizedBox(height: 4),
                PopupMenuButton<String>(
                  tooltip: 'Application actions',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 150),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: context.muted,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
