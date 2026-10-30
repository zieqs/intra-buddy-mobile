import 'package:flutter/material.dart';

import '../domain/journey.dart';
import 'widgets/celebration_overlay.dart';

Future<void> celebrate({
  required BuildContext context,
  required JourneyNode node,
  required Journey journey,
}) async {
  final weeks = journey
          .chapterFor(JourneyChapterKind.during)
          ?.nodes
          .where((item) => item.isWeek)
          .length ??
      0;
  final current = node.weekNumber ?? weeks;
  final remaining = weeks - current;

  final headline = node.isWeek ? 'Week $current done!' : 'Milestone done!';
  final subline = node.isWeek
      ? remaining <= 0
            ? 'Final week done · ${journey.streak}-week streak'
            : '$remaining to go · ${journey.streak}-week streak'
      : '${node.title} · ${journey.streak}-week streak';

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    pageBuilder: (dialogContext, _, _) => CelebrationOverlay(
      headline: headline,
      subline: subline,
      streak: journey.streak,
      progress: journey.progress,
      progressLabel: '${journey.completedNodes} of ${journey.totalNodes} done',
      onContinue: () => Navigator.of(dialogContext).pop(),
    ),
  );
}
