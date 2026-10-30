import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../domain/journey.dart';
import '../../domain/journey_copy.dart';
import 'current_task_card.dart';
import 'trail_chapter.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.journey,
    required this.userName,
    required this.bell,
    required this.onProfile,
    required this.onLogbook,
    required this.onAction,
    required this.onRefresh,
    this.now,
  });

  final Journey journey;
  final String userName;
  final Widget bell;
  final VoidCallback onProfile;
  final VoidCallback onLogbook;
  final ValueChanged<JourneyNode> onAction;
  final Future<void> Function() onRefresh;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final reference = now ?? DateTime.now();
    final topBar = BuddyTopBar(
      brand: 'INTRA BUDDY',
      streak: journey.streak,
      userName: userName,
      bell: bell,
      onProfile: onProfile,
    );

    if (journey.isEmpty) {
      return BuddyScaffold(
        topBar: topBar,
        onRefresh: onRefresh,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              headline: 'Your journey starts here.',
              body: 'Ask your coordinator to add the first milestone.',
              actionLabel: 'Open logbook',
              onAction: onLogbook,
            ),
          ),
        ],
      );
    }

    final currentWeek = journey.currentWeek;
    final nextAction = journey.nextAction;
    final weeks = journey
            .chapterFor(JourneyChapterKind.during)
            ?.nodes
            .where((node) => node.isWeek)
            .length ??
        0;

    final actionLabel = nextAction == null
        ? 'Mark done'
        : nextAction.isWeek
        ? 'Open week ${nextAction.weekNumber}'
        : nextAction.canComplete
        ? 'Mark done'
        : 'Review milestone';

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
                  currentWeek != null
                      ? 'WEEK ${currentWeek.weekNumber} OF $weeks'
                      : journey.anchorKind == JourneyChapterKind.before
                      ? 'GETTING READY'
                      : journey.anchorKind == JourneyChapterKind.after
                      ? 'WRAPPING UP'
                      : 'YOUR JOURNEY',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: context.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  homeHeadline(journey),
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: context.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  homeSubline(journey),
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
            child: CurrentTaskCard(
              node: nextAction,
              dueLabel: nextAction?.dueDate == null
                  ? null
                  : dueDateLabel(nextAction!.dueDate!, reference),
              actionLabel: actionLabel,
              onAction: nextAction == null ? null : () => onAction(nextAction),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                for (final chapter in journey.chapters) ...[
                  TrailChapter(
                    chapter: chapter,
                    nextActionId: nextAction?.id,
                    now: reference,
                    onNodeTap: onAction,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: context.line, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreakBadge(streak: journey.streak, compact: true),
                  const SizedBox(height: 6),
                  Text(
                    journey.streak == 0
                        ? 'Submit this week to start a streak.'
                        : '${journey.streak}-week streak · every logbook on time.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
