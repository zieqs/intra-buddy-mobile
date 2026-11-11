import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/coordinator_contact.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../enrollment/presentation/providers/enrollment_provider.dart';
import '../../../enrollment/presentation/widgets/semester_card.dart';
import '../../../journey/presentation/celebration_sound_settings.dart';
import '../../../logbook/presentation/services/logbook_reminder_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEnabled =
        ref.watch(celebrationSoundEnabledProvider).value ?? true;
    final enrollment = ref.watch(currentEnrollmentProvider);
    final contact = configuredCoordinatorContact();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          enrollment.when(
            loading: () => const SemesterCard(loading: true),
            error: (error, _) => SemesterCard(
              error: true,
              caption: 'Check your connection and try again.',
              onRetry: () => ref.invalidate(currentEnrollmentProvider),
              onContact: contact == null
                  ? null
                  : () => launchUrl(
                      contact,
                      mode: LaunchMode.externalApplication,
                    ),
            ),
            data: (value) => SemesterCard(
              enrollment: value,
              caption: value == null
                  ? 'Ask your coordinator to enroll you in your INTRA session.'
                  : 'Not your session? Contact your coordinator.',
              onContact: contact == null
                  ? null
                  : () => launchUrl(
                      contact,
                      mode: LaunchMode.externalApplication,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text('App Version'),
                  trailing: Text(
                    '0.1.0+1',
                    style: TextStyle(color: context.muted),
                  ),
                ),
                if (kDebugMode) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Send test notification'),
                    subtitle: const Text('Debug builds only'),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final shown = await LogbookReminderService.instance
                          .showTestNotification();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            shown
                                ? 'Test notification sent'
                                : 'Notifications are not available',
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.celebration_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Celebration sounds'),
                  subtitle: const Text(
                    'A short chime when you complete a step',
                  ),
                  value: soundEnabled,
                  onChanged: (value) => ref
                      .read(celebrationSoundEnabledProvider.notifier)
                      .setEnabled(value),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(authControllerProvider.notifier).signOut();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
