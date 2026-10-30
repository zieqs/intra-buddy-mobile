import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../domain/journey.dart';
import 'milestone_row.dart';
import 'week_track.dart';

class YourJourneyView extends StatelessWidget {
  const YourJourneyView({
    super.key,
    required this.journey,
    required this.userName,
    required this.bell,
    required this.onNodeTap,
    required this.onProfile,
    required this.onBack,
    this.now,
  });

  final Journey journey;
  final String userName;
  final Widget bell;
  final ValueChanged<JourneyNode> onNodeTap;
  final VoidCallback onProfile;
  final VoidCallback onBack;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final reference = now ?? DateTime.now();
    final topBar = BuddyTopBar(
      brand: 'YOUR JOURNEY',
      streak: journey.streak,
      userName: userName,
      bell: bell,
      onProfile: onProfile,
      onBack: onBack,
    );

    if (journey.isEmpty) {
      return BuddyScaffold(
        topBar: topBar,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              headline: 'Your journey starts here.',
              body: 'Ask your coordinator to add the first milestone.',
              actionLabel: 'Go back',
              onAction: onBack,
            ),
          ),
        ],
      );
    }

    final weeks = journey
            .chapterFor(JourneyChapterKind.during)
            ?.nodes
            .where((node) => node.isWeek)
            .length ??
        0;
    final milestoneCount = journey.chapters
        .where((chapter) => chapter.kind != JourneyChapterKind.during)
        .fold<int>(0, (sum, chapter) => sum + chapter.total);
    final wrapUp = journey.chapterFor(JourneyChapterKind.after)?.total ?? 0;

    return BuddyScaffold(
      topBar: topBar,
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
                  'The whole story.',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: context.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '$milestoneCount milestones · $weeks weeks · $wrapUp to wrap up',
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
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              for (final chapter in journey.chapters)
                _ChapterBlock(
                  chapter: chapter,
                  now: reference,
                  onNodeTap: onNodeTap,
                ),
              const SizedBox(height: AppSpacing.lg),
              _ProgressCard(journey: journey),
              const SizedBox(height: AppSpacing.xxxl),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ChapterBlock extends StatelessWidget {
  const _ChapterBlock({
    required this.chapter,
    required this.now,
    required this.onNodeTap,
  });

  final JourneyChapter chapter;
  final DateTime now;
  final ValueChanged<JourneyNode> onNodeTap;

  @override
  Widget build(BuildContext context) {
    final weeks = chapter.nodes.where((node) => node.isWeek).toList();
    final milestones = chapter.nodes.where((node) => !node.isWeek).toList();
    final dotColor = chapter.completed == chapter.total
        ? context.blue
        : chapter.completed == 0
        ? context.lineStrong
        : context.sun;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chapter.title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.ink,
                  ),
                ),
              ),
              Text(
                '${chapter.completed} / ${chapter.total}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: context.line, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (weeks.isNotEmpty) ...[
                  WeekTrack(weeks: weeks, onTap: onNodeTap),
                  const SizedBox(height: AppSpacing.sm),
                ],
                for (final node in milestones)
                  MilestoneRow(
                    node: node,
                    now: now,
                    onTap: () => onNodeTap(node),
                  ),
                if (weeks.isEmpty && milestones.isEmpty)
                  Text(
                    'Nothing assigned yet.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.muted,
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.journey});

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: context.line, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Journey progress',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.ink,
                  ),
                ),
              ),
              Text(
                '${journey.completedNodes} of ${journey.totalNodes} done',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: journey.progress,
              minHeight: 8,
              color: context.blue,
              backgroundColor: context.line,
            ),
          ),
        ],
      ),
    );
  }
}
