import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_controller.dart';

/// Bell icon with an unread badge.
///
/// Watches the notifications inbox, so the badge stays in sync with any
/// read/delete action taken elsewhere in the app. Refreshes on app resume.
class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell>
    with WidgetsBindingObserver {
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
      ref.invalidate(notificationControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      tooltip: unread > 0 ? 'Notifications — $unread unread' : 'Notifications',
      onPressed: () => context.push('/notifications'),
      icon: Badge.count(
        count: unread,
        maxCount: 99,
        isLabelVisible: unread > 0,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
