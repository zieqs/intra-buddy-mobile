import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';
import '../notification_time.dart';

/// Compact dashboard strip showing the newest non-archived notification.
///
/// Renders an explicit empty/loading/error state when there is nothing to
/// show, so the dashboard never silently drops the section.
class LatestNotificationBanner extends StatelessWidget {
  final AppNotification? notification;
  final int unreadCount;
  final String? imageUrl;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  const LatestNotificationBanner({
    super.key,
    required this.notification,
    this.unreadCount = 0,
    this.imageUrl,
    this.isLoading = false,
    this.hasError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final current = notification;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: current == null ? _empty(context) : _content(context, current),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final title = isLoading
        ? 'Loading notifications…'
        : hasError
        ? "Couldn't load notifications"
        : 'No notifications';
    final subtitle = isLoading
        ? null
        : hasError
        ? 'Open the inbox to try again'
        : "You're all caught up";

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.primaryContainer,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  hasError ? Icons.error_outline : Icons.notifications_none,
                  color: AppColors.primary,
                  size: 22,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.muted),
              ),
              const SizedBox(height: 3),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }

  Widget _content(BuildContext context, AppNotification current) {
    final isUnread = !current.isRead;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leading(context, current),
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.muted),
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    Text(
                      '$unreadCount unread',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    timeAgo(current.createdAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: context.muted),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                current.title ?? 'Notification',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (current.body != null) ...[
                const SizedBox(height: 2),
                Text(
                  current.body!,
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
    );
  }

  Widget _leading(BuildContext context, AppNotification current) {
    final url = imageUrl;
    if (url == null) return _icon(context, current);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          url,
          key: const ValueKey('latest-notification-image'),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _icon(context, current),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context, AppNotification current) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.primaryContainer,
      ),
      child: Icon(
        current.type == 'broadcast'
            ? Icons.campaign_outlined
            : Icons.notifications_outlined,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
