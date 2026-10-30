import 'dart:math' as math;

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
    required this.onJourney,
    required this.onChecklist,
    required this.onAction,
    required this.onRefresh,
    this.now,
  });

  final Journey journey;
  final String userName;
  final Widget bell;
  final VoidCallback onProfile;
  final VoidCallback onJourney;
  final VoidCallback onChecklist;
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
              actionLabel: 'Open checklist',
              onAction: onChecklist,
            ),
          ),
        ],
      );
    }

    final currentChapter =
        journey.chapterFor(journey.anchorKind) ?? journey.chapters.first;
    final currentIndex = journey.chapters.indexOf(currentChapter);
    final past = journey.chapters.take(currentIndex).toList();
    final future = journey.chapters.skip(currentIndex + 1).toList();
    final currentWeek = journey.currentWeek;
    final nextAction = journey.nextAction;
    final weeks = journey
        .chapterFor(JourneyChapterKind.during)
        ?.nodes
        .where((node) => node.isWeek)
        .length;

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
                      ? 'WEEK ${currentWeek.weekNumber} OF ${weeks ?? 0}'
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
              actionLabel: nextAction == null
                  ? 'Mark done'
                  : nextAction.isWeek
                  ? nextAction.canComplete
                        ? 'Mark submitted'
                        : 'View logbook'
                  : nextAction.canComplete
                  ? 'Mark done'
                  : 'Open checklist',
              onAction: nextAction == null ? null : () => onAction(nextAction),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        if (past.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  for (final chapter in past)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ChapterPill(
                        title: chapter.title,
                        done: chapter.completed,
                        total: chapter.total,
                        onTap: onJourney,
                      ),
                    ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _ScrollToCurrent(
              currentNodeId: currentWeek?.id,
              builder: (key) => TrailChapter(
                chapter: currentChapter,
                visibleNodes: _window(currentChapter, currentWeek),
                currentNodeId: currentWeek?.id,
                currentNodeKey: key,
                nextActionId: nextAction?.id,
                now: reference,
                onNodeTap: onAction,
              ),
            ),
          ),
        ),
        if (future.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  for (final chapter in future)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ChapterPill(
                        title: chapter.title,
                        done: chapter.completed,
                        total: chapter.total,
                        locked:
                            chapter.kind == JourneyChapterKind.after &&
                            chapter.completed < chapter.total,
                        onTap: onJourney,
                      ),
                    ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onJourney,
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: context.blue,
                ),
                label: Text(
                  'VIEW FULL JOURNEY',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: context.blue),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<JourneyNode> _window(JourneyChapter chapter, JourneyNode? current) {
    if (chapter.nodes.length <= 5) return chapter.nodes;
    final index = current == null
        ? 0
        : math.max(
            0,
            chapter.nodes.indexWhere((node) => node.id == current.id),
          );
    final start = math.max(0, index - 2);
    final end = math.min(chapter.nodes.length, index + 3);
    return chapter.nodes.sublist(start, end);
  }
}

class _ScrollToCurrent extends StatefulWidget {
  const _ScrollToCurrent({
    required this.currentNodeId,
    required this.builder,
  });

  final String? currentNodeId;
  final Widget Function(GlobalKey key) builder;

  @override
  State<_ScrollToCurrent> createState() => _ScrollToCurrentState();
}

class _ScrollToCurrentState extends State<_ScrollToCurrent> {
  final _key = GlobalKey();
  bool _didScroll = false;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _ScrollToCurrent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentNodeId != widget.currentNodeId) {
      _didScroll = false;
      _schedule();
    }
  }

  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didScroll) return;
      final nodeContext = _key.currentContext;
      if (nodeContext == null) return;
      _didScroll = true;
      final reduced =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      Scrollable.ensureVisible(
        nodeContext,
        alignment: 0.3,
        duration: reduced ? Duration.zero : AppDurations.standard,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(_key);
}
