import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../domain/journey.dart';
import '../../domain/journey_copy.dart';
import 'current_task_card.dart';
import 'trail_chapter.dart';

class HomeView extends StatefulWidget {
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
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey _focusKey = GlobalKey();

  JourneyNode? _focusNode(Journey journey) =>
      journey.nextAction ?? journey.currentWeek;

  @override
  void initState() {
    super.initState();
    _scheduleFocus();
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = _focusNode(oldWidget.journey)?.id;
    final after = _focusNode(widget.journey)?.id;
    if (after != null && after != before) _scheduleFocus();
  }

  void _scheduleFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final nodeContext = _focusKey.currentContext;
      if (nodeContext == null) return;

      Scrollable.ensureVisible(
        nodeContext,
        alignment: 0.02,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;
    final reference = widget.now ?? DateTime.now();
    final topBar = BuddyTopBar(
      brand: 'INTRA BUDDY',
      streak: journey.streak,
      userName: widget.userName,
      bell: widget.bell,
      onProfile: widget.onProfile,
      onStreakTap: widget.onLogbook,
    );

    if (journey.isEmpty) {
      return BuddyScaffold(
        topBar: topBar,
        onRefresh: widget.onRefresh,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              headline: 'Your journey starts here.',
              body: 'Ask your coordinator to add the first milestone.',
              actionLabel: 'Open logbook',
              onAction: widget.onLogbook,
            ),
          ),
        ],
      );
    }

    final currentWeek = journey.currentWeek;
    final nextAction = journey.nextAction;
    final focusNode = _focusNode(journey);
    final weeks =
        journey
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
      onRefresh: widget.onRefresh,
      header: Padding(
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
            _HeroSubline(journey: journey),
            const SizedBox(height: AppSpacing.lg),
            CurrentTaskCard(
              node: nextAction,
              dueLabel: nextAction?.dueDate == null
                  ? null
                  : dueDateLabel(nextAction!.dueDate!, reference),
              actionLabel: actionLabel,
              onAction: nextAction == null
                  ? null
                  : () => widget.onAction(nextAction),
            ),
          ],
        ),
      ),
      slivers: [
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
                    onNodeTap: widget.onAction,
                    currentNodeId: focusNode?.id,
                    currentNodeKey: _focusKey,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
      ],
    );
  }
}

class _HeroSubline extends StatelessWidget {
  const _HeroSubline({required this.journey});

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    final lead = homeSublineLead(journey);
    final streak = homeStreakText(journey);
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: context.muted);

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: lead),
          if (streak != null) ...[
            const TextSpan(text: ' · '),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 14,
                  color: AppColors.flame,
                ),
              ),
            ),
            TextSpan(text: streak),
          ],
        ],
      ),
    );
  }
}
