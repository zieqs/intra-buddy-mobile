import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/checklist_item.dart';
import '../providers/checklist_controller.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistState = ref.watch(checklistControllerProvider);

    return checklistState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load checklist',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(checklistControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checklist, size: 64, color: context.muted),
                const SizedBox(height: 16),
                Text(
                  'No checklist items yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        final completed = items.where((i) => i.isCompleted).length;
        final total = items.length;
        final progress = total > 0 ? completed / total : 0.0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestone Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: context.outline,
                        valueColor: AlwaysStoppedAnimation(
                          progress == 1.0
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed / $total completed',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: context.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _ChecklistTile(item: item)),
          ],
        );
      },
    );
  }
}

class _ChecklistTile extends ConsumerWidget {
  final ChecklistItem item;

  const _ChecklistTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: item.isCompleted,
        onChanged: (value) {
          ref
              .read(checklistControllerProvider.notifier)
              .toggleItem(item.id, value ?? false);
        },
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? context.muted : null,
          ),
        ),
        subtitle: item.description != null
            ? Text(item.description!, style: TextStyle(color: context.muted))
            : null,
        activeColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
