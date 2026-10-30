import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../journey/domain/journey.dart';
import '../../../journey/presentation/celebration_controller.dart';
import '../../../journey/presentation/celebration_providers.dart';
import '../../../journey/presentation/celebration_sound_settings.dart';
import '../../../journey/presentation/providers/journey_provider.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../logbook_week_info.dart';
import '../providers/logbook_controller.dart';
import '../widgets/logbook_view.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen>
    with WidgetsBindingObserver {
  Journey? _lastJourney;

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
    final logbookAsync = ref.watch(logbookControllerProvider);
    final journeyAsync = ref.watch(journeyProvider);
    _lastJourney = journeyAsync.value ?? _lastJourney;
    final journey = _lastJourney;
    final auth = ref.watch(authControllerProvider);
    final userName = auth.value?.fullName ?? 'Student';
    final streak = journey?.streak ?? 0;

    final topBar = BuddyTopBar(
      brand: 'LOGBOOK',
      streak: streak,
      userName: userName,
      bell: const NotificationBell(),
      onProfile: () => context.push('/profile'),
    );

    return logbookAsync.when(
      loading: () => BuddyScaffold(
        topBar: topBar,
        slivers: const [
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.xl),
            sliver: SliverToBoxAdapter(child: _Skeleton()),
          ),
        ],
      ),
      error: (error, _) => BuddyScaffold(
        topBar: topBar,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              headline: "Couldn't load your logbook.",
              body: 'Check your connection and try again.',
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(logbookControllerProvider),
            ),
          ),
        ],
      ),
      data: (weeks) {
        if (weeks.isEmpty) {
          return BuddyScaffold(
            topBar: topBar,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  headline: 'No logbook yet.',
                  body: 'Your weeks will appear once the semester starts.',
                  actionLabel: 'Back home',
                  onAction: () => context.go('/dashboard'),
                ),
              ),
            ],
          );
        }

        final summary = buildLogbookSummary(weeks, DateTime.now());
        final start = journey?.semesterStart;
        final beforeStart = start != null && DateTime.now().isBefore(start);
        return LogbookView(
          summary: summary,
          streak: streak,
          canSubmit: journey != null && !beforeStart,
          userName: userName,
          bell: const NotificationBell(),
          onProfile: () => context.push('/profile'),
          onWeekTap: _openWeek,
          onRefresh: () async {
            ref.invalidate(logbookControllerProvider);
            ref.invalidate(journeyProvider);
            await ref.read(logbookControllerProvider.future);
          },
        );
      },
    );
  }

  Future<void> _openWeek(LogbookWeekInfo info) async {
    final submitted = !info.week.isSubmitted;
    if (!submitted && !info.canSubmit) return;

    final confirmed = await _confirm(context, info, submitted: submitted);
    if (!confirmed || !mounted) return;

    final ok = await ref
        .read(logbookControllerProvider.notifier)
        .toggleSubmitted(info.week.id, submitted);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the logbook. Try again.')),
      );
      return;
    }

    ref.invalidate(journeyProvider);
    if (!submitted) return;

    final updated = await ref.read(journeyProvider.future);
    if (!mounted) return;
    await celebrate(
      context: context,
      node: _weekNode(updated, info),
      journey: updated,
      feedback: ref.read(celebrationFeedbackProvider),
      soundEnabled: ref.read(celebrationSoundEnabledProvider).value ?? true,
    );
  }

  JourneyNode _weekNode(Journey journey, LogbookWeekInfo info) {
    for (final chapter in journey.chapters) {
      for (final node in chapter.nodes) {
        if (node.isWeek && node.weekNumber == info.week.weekNumber) return node;
      }
    }
    return JourneyNode(
      id: 'week-${info.week.weekNumber}',
      kind: JourneyNodeKind.week,
      title: 'Week ${info.week.weekNumber}',
      chapter: JourneyChapterKind.during,
      state: JourneyNodeState.done,
      dueDate: info.week.weekEndDate,
      weekNumber: info.week.weekNumber,
      sourceId: info.week.id,
      isCompleted: true,
    );
  }

  Future<bool> _confirm(
    BuildContext context,
    LogbookWeekInfo info, {
    required bool submitted,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  submitted
                      ? 'Mark Week ${info.week.weekNumber} as submitted?'
                      : 'Undo Week ${info.week.weekNumber} submission?',
                  style: Theme.of(sheetContext).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  submitted
                      ? "INTRA Buddy doesn't upload your logbook. Mark this after you've submitted it through the INTRA portal."
                      : 'This will mark the week as not submitted. You can mark it again later.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: context.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: submitted ? 'Mark submitted' : 'Undo submission',
                  onPressed: () => Navigator.pop(sheetContext, true),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result == true;
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget block() => Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: context.line, width: 1.5),
      ),
    );

    return Column(children: [block(), block(), block()]);
  }
}
