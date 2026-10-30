import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/primary_button.dart';
import '../../domain/journey.dart';

class CurrentTaskCard extends StatelessWidget {
  const CurrentTaskCard({
    super.key,
    required this.node,
    this.dueLabel,
    this.actionLabel = 'Mark done',
    this.onAction,
  });

  final JourneyNode? node;
  final String? dueLabel;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final current = node;
    final content = current == null
        ? _empty(context)
        : _task(context, current);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: context.line, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: AnimatedSize(
        duration: AppDurations.standard,
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: AppDurations.standard,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(current?.id ?? 'empty'),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UP NEXT',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.blue),
        ),
        const SizedBox(height: 4),
        Text(
          "You're all caught up.",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: context.ink),
        ),
      ],
    );
  }

  Widget _task(BuildContext context, JourneyNode current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UP NEXT',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.blue),
        ),
        const SizedBox(height: 4),
        Text(
          current.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: context.ink),
        ),
        if (dueLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            dueLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.muted),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: actionLabel,
          onPressed: onAction,
          icon: Icons.check_rounded,
        ),
      ],
    );
  }
}
