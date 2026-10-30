import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/ui/ui.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../domain/journey.dart';
import '../providers/journey_provider.dart';
import '../widgets/your_journey_view.dart';

class YourJourneyScreen extends ConsumerWidget {
  const YourJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyProvider);
    final auth = ref.watch(authControllerProvider);
    final userName = auth.value?.fullName ?? 'Student';

    final topBar = BuddyTopBar(
      brand: 'YOUR JOURNEY',
      streak: journeyAsync.value?.streak ?? 0,
      userName: userName,
      bell: const NotificationBell(),
      onProfile: () => context.push('/profile'),
      onBack: () => context.pop(),
    );

    return journeyAsync.when(
      loading: () => BuddyScaffold(
        topBar: topBar,
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
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
      data: (journey) => YourJourneyView(
        journey: journey,
        userName: userName,
        bell: const NotificationBell(),
        onNodeTap: (node) => _openNode(context, node),
        onProfile: () => context.push('/profile'),
        onBack: () => context.pop(),
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
