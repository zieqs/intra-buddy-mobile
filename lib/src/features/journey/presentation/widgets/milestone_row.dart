import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/journey.dart';
import '../../domain/journey_copy.dart';

class MilestoneRow extends StatelessWidget {
  const MilestoneRow({
    super.key,
    required this.node,
    required this.onTap,
    this.now,
  });

  final JourneyNode node;
  final VoidCallback onTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final reference = now ?? DateTime.now();
    final background = switch (node.state) {
      JourneyNodeState.done => context.blue,
      JourneyNodeState.missed => context.alert,
      JourneyNodeState.locked => context.ice,
      _ => context.card,
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: node.state == JourneyNodeState.open
                      ? context.line
                      : background,
                  width: 1.5,
                ),
              ),
              child: node.state == JourneyNodeState.done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: AppColors.white,
                    )
                  : node.state == JourneyNodeState.missed
                  ? const Icon(
                      Icons.priority_high_rounded,
                      size: 15,
                      color: AppColors.white,
                    )
                  : node.state == JourneyNodeState.locked
                  ? Icon(Icons.lock_rounded, size: 13, color: context.muted)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    nodeStatusLabel(node, reference),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: context.muted),
          ],
        ),
      ),
    );
  }
}
