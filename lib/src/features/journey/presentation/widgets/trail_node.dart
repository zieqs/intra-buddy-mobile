import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../domain/journey.dart';
import '../../domain/journey_copy.dart';

class TrailNode extends StatelessWidget {
  const TrailNode({
    super.key,
    required this.node,
    required this.onTap,
    this.isNext = false,
    this.now,
  });

  final JourneyNode node;
  final VoidCallback onTap;
  final bool isNext;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final reference = now ?? DateTime.now();
    final isWeek = node.kind == JourneyNodeKind.week;
    final status = nodeStatusLabel(node, reference);

    final (Color background, Color foreground, Color border) = switch (node.state) {
      JourneyNodeState.done => (context.blue, AppColors.white, context.blue),
      JourneyNodeState.current => (context.sun, context.sunText, context.sun),
      JourneyNodeState.missed => (context.alert, AppColors.white, context.alert),
      JourneyNodeState.locked => (context.ice, context.muted, context.lineStrong),
      JourneyNodeState.open => (context.card, context.blue, context.line),
    };

    final size = node.state == JourneyNodeState.current ? 58.0 : 44.0;

    final Widget content;
    if (isWeek) {
      content = node.state == JourneyNodeState.done
          ? const Icon(
              Icons.check_rounded,
              size: 22,
              color: AppColors.white,
            )
          : node.state == JourneyNodeState.missed
          ? const Icon(
              Icons.priority_high_rounded,
              size: 22,
              color: AppColors.white,
            )
          : Text(
              '${node.weekNumber}',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: size == 58 ? 24 : 16,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            );
    } else {
      content = node.state == JourneyNodeState.done
          ? const Icon(
              Icons.check_rounded,
              size: 22,
              color: AppColors.white,
            )
          : node.state == JourneyNodeState.missed
          ? const Icon(
              Icons.priority_high_rounded,
              size: 22,
              color: AppColors.white,
            )
          : node.state == JourneyNodeState.locked
          ? Icon(Icons.lock_rounded, size: 18, color: context.muted)
          : const Icon(Icons.circle, size: 7, color: AppColors.blue);
    }

    final nodeBody = AnimatedContainer(
      key: ValueKey(node.id),
      duration: AppDurations.standard,
      curve: Curves.easeOut,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: isWeek ? BoxShape.circle : BoxShape.rectangle,
        color: background,
        borderRadius: isWeek ? null : BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: AnimatedSwitcher(
        duration: AppDurations.quick,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: KeyedSubtree(
          key: ValueKey('${node.state}-${node.kind}'),
          child: content,
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: AppDurations.standard,
                      width: 6,
                      color: switch (node.state) {
                        JourneyNodeState.done => context.blue,
                        JourneyNodeState.current => context.sun,
                        JourneyNodeState.missed => context.alert,
                        JourneyNodeState.locked => context.lineStrong,
                        JourneyNodeState.open => context.line,
                      },
                    ),
                  ),
                  Center(child: nodeBody),
                ],
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding: const EdgeInsets.fromLTRB(8, 10, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isNext)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          'UP NEXT',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: context.blue),
                        ),
                      ),
                    Text(
                      node.title,
                      style: (isWeek
                              ? Theme.of(context).textTheme.titleLarge
                              : Theme.of(context).textTheme.titleMedium)
                          ?.copyWith(color: context.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
