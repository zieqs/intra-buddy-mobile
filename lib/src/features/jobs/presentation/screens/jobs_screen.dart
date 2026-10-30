import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/ui.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../journey/presentation/providers/journey_provider.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../domain/entities/job_application.dart';
import '../providers/job_controller.dart';
import '../widgets/job_form.dart';
import '../widgets/jobs_view.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobControllerProvider);
    final journey = ref.watch(journeyProvider).value;
    final auth = ref.watch(authControllerProvider);
    final userName = auth.value?.fullName ?? 'Student';
    final items = jobs.value;

    final topBar = BuddyTopBar(
      brand: 'JOBS',
      streak: journey?.streak ?? 0,
      userName: userName,
      bell: const NotificationBell(),
      onProfile: () => context.push('/profile'),
    );

    if (items == null) {
      if (jobs.hasError) {
        return BuddyScaffold(
          topBar: topBar,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                headline: "Couldn't load applications.",
                body: 'Check your connection and try again.',
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(jobControllerProvider),
              ),
            ),
          ],
        );
      }

      return BuddyScaffold(
        topBar: topBar,
        slivers: const [
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.xl),
            sliver: SliverToBoxAdapter(child: _Skeleton()),
          ),
        ],
      );
    }

    return JobsView(
      items: items,
      streak: journey?.streak ?? 0,
      userName: userName,
      bell: const NotificationBell(),
      onProfile: () => context.push('/profile'),
      onAdd: () => showJobForm(context),
      onEdit: (item) => showJobForm(context, existing: item),
      onDelete: (item) => _confirmDelete(context, ref, item),
      onRefresh: () async {
        ref.invalidate(jobControllerProvider);
        await ref.read(jobControllerProvider.future);
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    JobApplication item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete application?'),
        content: Text('Remove the application to ${item.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await ref.read(jobControllerProvider.notifier).deleteApplication(item.id);
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget block() => Container(
      height: 72,
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
