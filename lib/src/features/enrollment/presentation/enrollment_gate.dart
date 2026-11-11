import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/coordinator_contact.dart';
import '../../auth/presentation/providers/auth_controller.dart';
import 'providers/enrollment_provider.dart';

/// Keeps the signed-in app behind an explicit enrollment state.
///
/// A student whose account has no `student_semesters` row would otherwise see
/// empty screens that look like broken data. This turns that case into a clear
/// message with a refresh and a way to reach the coordinator.
class EnrollmentGate extends ConsumerWidget {
  const EnrollmentGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollment = ref.watch(currentEnrollmentProvider);

    return enrollment.when(
      loading: () => const _EnrollmentLoading(),
      error: (error, _) => const EnrollmentPendingScreen(
        title: "We couldn't check your enrollment",
        message:
            'Check your connection and try again. If this keeps happening, '
            'contact your coordinator.',
      ),
      data: (value) {
        if (value == null) return const EnrollmentPendingScreen();
        return child;
      },
    );
  }
}

class EnrollmentPendingScreen extends ConsumerWidget {
  const EnrollmentPendingScreen({
    super.key,
    this.title = "You're not enrolled yet",
    this.message =
        'Ask your coordinator to add you to your INTRA session, then refresh. '
        'You will see your checklist and logbook once you are enrolled.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = configuredCoordinatorContact();

    return Scaffold(
      backgroundColor: context.page,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.primaryContainer,
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: context.muted),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ref.invalidate(currentEnrollmentProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('REFRESH'),
                  ),
                ),
                if (contact != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => launchUrl(
                        contact,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.support_agent_outlined),
                      label: const Text('Contact coordinator'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  child: Text(
                    'Sign out',
                    style: TextStyle(color: context.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnrollmentLoading extends StatelessWidget {
  const _EnrollmentLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.page,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
