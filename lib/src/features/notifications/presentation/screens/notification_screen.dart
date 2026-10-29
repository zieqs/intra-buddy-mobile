import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_controller.dart';
import '../widgets/notification_image_strip.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationControllerProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final readCount = (notifState.value?.length ?? 0) - unread;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton.icon(
              onPressed: () => ref
                  .read(notificationControllerProvider.notifier)
                  .markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
            ),
          if (readCount > 0)
            PopupMenuButton<String>(
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'archive_read') {
                  _confirmArchiveRead(context, ref);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'archive_read',
                  child: Text('Archive read'),
                ),
              ],
            ),
        ],
      ),
      body: notifState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(notificationControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 64,
                    color: context.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're all caught up!",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: context.muted),
                  ),
                ],
              ),
            );
          }

          final grouped = _groupNotifications(items);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final group in grouped) ...[
                if (grouped.indexOf(group) > 0) const SizedBox(height: 8),
                Text(
                  group.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: context.muted),
                ),
                const SizedBox(height: 8),
                ...group.items.map(
                  (item) => _NotificationCard(
                    notification: item,
                    isFirst: group.items.first == item,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmArchiveRead(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive read notifications?'),
        content: const Text(
          "This removes notifications you've already read from your inbox. They are kept for INTRA records. Unread notifications stay.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final archived = await ref
        .read(notificationControllerProvider.notifier)
        .archiveReadNotifications();
    if (!context.mounted) return;

    final message = archived == null
        ? 'Could not archive notifications. Please try again.'
        : archived == 0
        ? 'No read notifications to archive.'
        : 'Archived $archived read notification${archived == 1 ? '' : 's'}.';
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  List<_NotificationGroup> _groupNotifications(List<AppNotification> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final todayItems = <AppNotification>[];
    final weekItems = <AppNotification>[];
    final earlierItems = <AppNotification>[];

    for (final item in items) {
      final itemDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      if (itemDate == today) {
        todayItems.add(item);
      } else if (itemDate.isAfter(
        weekStart.subtract(const Duration(days: 1)),
      )) {
        weekItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    final groups = <_NotificationGroup>[];
    if (todayItems.isNotEmpty) {
      groups.add(_NotificationGroup('Today', todayItems));
    }
    if (weekItems.isNotEmpty) {
      groups.add(_NotificationGroup('This Week', weekItems));
    }
    if (earlierItems.isNotEmpty) {
      groups.add(_NotificationGroup('Earlier', earlierItems));
    }
    return groups;
  }
}

class _NotificationGroup {
  final String label;
  final List<AppNotification> items;
  const _NotificationGroup(this.label, this.items);
}

class _NotificationCard extends ConsumerWidget {
  final AppNotification notification;
  final bool isFirst;

  const _NotificationCard({required this.notification, this.isFirst = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseClientProvider);
    final imageUrls = notification.imagePaths
        .map(
          (path) => supabase.storage.from('broadcast-media').getPublicUrl(path),
        )
        .toList();

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.archive_outlined, color: Colors.white),
      ),
      onDismissed: (_) {
        ref
            .read(notificationControllerProvider.notifier)
            .removeArchived(notification.id);
      },
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        final archived = await ref
            .read(notificationControllerProvider.notifier)
            .archiveNotification(notification.id);
        if (!archived && context.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Could not archive the notification. Please try again.',
              ),
            ),
          );
        }
        return archived;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notification.isRead) {
              ref
                  .read(notificationControllerProvider.notifier)
                  .markAsRead(notification.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: notification.isRead
                        ? Colors.transparent
                        : AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification.title != null)
                        Text(
                          notification.title!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                        ),
                      if (notification.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.muted),
                        ),
                      ],
                      if (imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        NotificationImageStrip(
                          imageUrls: imageUrls,
                          onTap: (index) =>
                              showNotificationImage(context, imageUrls, index),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(notification.createdAt),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: context.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
