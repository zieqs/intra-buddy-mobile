import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/journey.dart';

class WeekTrack extends StatelessWidget {
  const WeekTrack({super.key, required this.weeks, required this.onTap});

  final List<JourneyNode> weeks;
  final ValueChanged<JourneyNode> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < weeks.length; index++) ...[
            if (index > 0) const SizedBox(width: 5),
            _WeekDot(node: weeks[index], onTap: () => onTap(weeks[index])),
          ],
        ],
      ),
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.node, required this.onTap});

  final JourneyNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = node.state == JourneyNodeState.current ? 36.0 : 28.0;
    final (background, foreground) = switch (node.state) {
      JourneyNodeState.done => (context.blue, AppColors.white),
      JourneyNodeState.current => (context.sun, context.sunText),
      JourneyNodeState.missed => (context.alert, AppColors.white),
      JourneyNodeState.locked => (context.ice, context.muted),
      JourneyNodeState.open => (context.card, context.muted),
    };

    return Semantics(
      button: true,
      label: 'Week ${node.weekNumber}',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
              border: Border.all(
                color: node.state == JourneyNodeState.open
                    ? context.line
                    : background,
                width: 1.5,
              ),
            ),
            child: Text(
              '${node.weekNumber}',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: size == 36 ? 14 : 10,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
