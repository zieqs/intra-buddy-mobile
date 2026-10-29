import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';
import '../notification_time.dart';

/// Compact dashboard strip showing the newest non-archived notification.
class LatestNotificationBanner extends StatelessWidget {
  final AppNotification notification;
  final int unreadCount;
  final String? imageUrl;
  final VoidCallback onTap;

  const LatestNotificationBanner({
    super.key,
    required this.notification,
    required this.unreadCount,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _leading(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Latest notification',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: context.muted),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          Text(
                            '$unreadCount unread',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          timeAgo(notification.createdAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.title ?? 'Notification',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (notification.body != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        notification.body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: context.muted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: context.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leading(BuildContext context) {
    final url = imageUrl;
    if (url == null) return _icon(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          url,
          key: const ValueKey('latest-notification-image'),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _icon(context),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.primaryContainer,
      ),
      child: Icon(
        notification.type == 'broadcast'
            ? Icons.campaign_outlined
            : Icons.notifications_outlined,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
