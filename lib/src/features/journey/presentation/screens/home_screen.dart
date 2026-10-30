import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../checklist/presentation/providers/checklist_controller.dart';
import '../../../logbook/presentation/providers/logbook_controller.dart';
import '../../../notifications/presentation/providers/notification_controller.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../domain/journey.dart';
import '../celebration_controller.dart';
import '../providers/journey_provider.dart';
import '../widgets/home_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyProvider);
    final auth = ref.watch(authControllerProvider);
    final userName = auth.value?.fullName ?? 'Student';

    final topBar = BuddyTopBar(
      brand: 'INTRA BUDDY',
      streak: journeyAsync.value?.streak ?? 0,
      userName: userName,
      bell: const NotificationBell(),
      onProfile: () => context.push('/profile'),
    );

    return journeyAsync.when(
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
              headline: "Couldn't load your journey.",
              body: 'Check your connection and try again.',
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(journeyProvider),
            ),
          ),
        ],
      ),
      data: (journey) => HomeView(
        journey: journey,
        userName: userName,
        bell: const NotificationBell(),
        onProfile: () => context.push('/profile'),
        onJourney: () => context.push('/journey'),
        onChecklist: () => context.go('/checklist'),
        onAction: (node) => _handleAction(context, ref, node),
        onRefresh: () async {
          ref.invalidate(journeyProvider);
          ref.invalidate(notificationControllerProvider);
          await ref.read(journeyProvider.future);
        },
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    JourneyNode node,
  ) async {
    final sourceId = node.sourceId;
    if (sourceId == null) return;

    if (!node.canComplete) {
      if (node.isWeek) {
        context.push('/logbook');
      } else {
        context.go('/checklist');
      }
      return;
    }

    final confirmed = await _confirm(context, node);
    if (!confirmed || !context.mounted) return;

    var ok = false;
    if (node.isWeek) {
      await ref.read(logbookControllerProvider.future);
      ok = await ref
          .read(logbookControllerProvider.notifier)
          .toggleSubmitted(sourceId, true);
    } else {
      await ref.read(checklistControllerProvider.future);
      await ref
          .read(checklistControllerProvider.notifier)
          .toggleItem(sourceId, true);
      ok = !ref.read(checklistControllerProvider).hasError;
    }

    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't update. Try again.")),
        );
      }
      return;
    }

    ref.invalidate(journeyProvider);
    final updated = await ref.read(journeyProvider.future);
    if (!context.mounted) return;
    await celebrate(context: context, node: node, journey: updated);
  }

  Future<bool> _confirm(BuildContext context, JourneyNode node) async {
    final isWeek = node.isWeek;
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
                  isWeek
                      ? 'Mark week ${node.weekNumber} as submitted?'
                      : 'Mark this milestone as done?',
                  style: Theme.of(sheetContext).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isWeek
                      ? 'INTRA Buddy tracks your status. Submit the actual logbook through the INTRA portal.'
                      : 'You can undo this later from the checklist.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: context.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: isWeek ? 'Mark submitted' : 'Mark done',
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
