import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/journey.dart';
import 'trail_node.dart';

class TrailChapter extends StatelessWidget {
  const TrailChapter({
    super.key,
    required this.chapter,
    required this.onNodeTap,
    this.nextActionId,
    this.now,
    this.visibleNodes,
  });

  final JourneyChapter chapter;
  final ValueChanged<JourneyNode> onNodeTap;
  final String? nextActionId;
  final DateTime? now;
  final List<JourneyNode>? visibleNodes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chapter.title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.muted,
                  ),
                ),
              ),
              Text(
                '${chapter.completed} / ${chapter.total}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.blue,
                ),
              ),
            ],
          ),
        ),
        for (final node in visibleNodes ?? chapter.nodes)
          TrailNode(
            node: node,
            isNext: node.id == nextActionId,
            now: now,
            onTap: () => onNodeTap(node),
          ),
      ],
    );
  }
}
