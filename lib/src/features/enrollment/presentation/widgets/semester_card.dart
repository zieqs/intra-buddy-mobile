import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/enrollment.dart';
import '../semester_date_format.dart';

/// Read-only display of the student's INTRA session.
///
/// Used during signup (the session they are about to join) and in Settings
/// (the session they are enrolled in). The student never edits this; only the
/// coordinator can change it.
class SemesterCard extends StatelessWidget {
  const SemesterCard({
    super.key,
    this.enrollment,
    this.loading = false,
    this.error = false,
    this.title = 'INTRA Session',
    this.emptyLabel = 'No session assigned',
    this.caption,
    this.warning,
    this.onContact,
    this.onRetry,
    this.icon = Icons.school_outlined,
  });

  final Enrollment? enrollment;
  final bool loading;
  final bool error;
  final String title;
  final String emptyLabel;
  final String? caption;
  final String? warning;
  final VoidCallback? onContact;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final semester = enrollment;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: context.muted),
                      ),
                      const SizedBox(height: 2),
                      if (loading)
                        Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Checking your session…',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        )
                      else if (error)
                        Text(
                          "Couldn't load your session",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: context.alert),
                        )
                      else if (semester == null)
                        Text(
                          emptyLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: context.muted),
                        )
                      else ...[
                        Text(
                          semester.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatSemesterRange(
                            semester.startDate,
                            semester.endDate,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.muted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onRetry != null)
                  IconButton(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Retry',
                  ),
              ],
            ),
            if (caption != null) ...[
              const SizedBox(height: 8),
              Text(
                caption!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.muted),
              ),
            ],
            if (warning != null) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: context.alert),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warning!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.alert,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (onContact != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onContact,
                  child: const Text('Contact coordinator'),
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
