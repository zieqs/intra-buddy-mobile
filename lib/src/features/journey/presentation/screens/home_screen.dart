import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../notifications/presentation/providers/notification_controller.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../domain/journey.dart';
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
        onAction: (node) => _openNode(context, node),
        onRefresh: () async {
          ref.invalidate(journeyProvider);
          ref.invalidate(notificationControllerProvider);
          await ref.read(journeyProvider.future);
        },
      ),
    );
  }

  void _openNode(BuildContext context, JourneyNode node) {
    if (node.kind == JourneyNodeKind.week) {
      context.push('/logbook');
    } else {
      context.go('/checklist');
    }
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
