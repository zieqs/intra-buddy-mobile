import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.headline,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String headline;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: context.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}
