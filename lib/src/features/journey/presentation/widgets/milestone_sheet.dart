import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/primary_button.dart';
import '../../domain/journey.dart';
import '../../domain/journey_copy.dart';

enum MilestoneAction { complete, undo }

Future<MilestoneAction?> showMilestoneSheet(
  BuildContext context, {
  required JourneyNode node,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();

  return showModalBottomSheet<MilestoneAction>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final done = node.state == JourneyNodeState.done;
      final locked = node.state == JourneyNodeState.locked;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MILESTONE',
                style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                  color: sheetContext.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                node.title,
                style: Theme.of(sheetContext).textTheme.headlineMedium,
              ),
              if (node.dueDate != null) ...[
                const SizedBox(height: 2),
                Text(
                  dueDateLabel(node.dueDate!, reference),
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                    color: sheetContext.muted,
                  ),
                ),
              ],
              if (node.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  node.description!,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: sheetContext.muted,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (done)
                PrimaryButton(
                  label: 'Undo completion',
                  onPressed: () =>
                      Navigator.pop(sheetContext, MilestoneAction.undo),
                )
              else if (locked)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: sheetContext.ice,
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                  child: Text(
                    'This milestone opens later in the internship.',
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: sheetContext.muted,
                    ),
                  ),
                )
              else
                PrimaryButton(
                  label: 'Mark done',
                  onPressed: () =>
                      Navigator.pop(sheetContext, MilestoneAction.complete),
                ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
