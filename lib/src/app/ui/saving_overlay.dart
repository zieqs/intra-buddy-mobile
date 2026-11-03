import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Shows a blocking "Saving…" wheel above the current page.
///
/// Insert it before the network write and remove it when the write and any
/// refresh are done. Keeping it as an overlay avoids a route swap, so the page
/// underneath does not lose its scroll position.
OverlayEntry showSavingOverlay(
  BuildContext context, {
  String label = 'Saving…',
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(
    builder: (context) => _SavingOverlay(label: label),
  );
  overlay.insert(entry);
  return entry;
}

class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Colors.black26),
        Center(
          child: Semantics(
            label: label,
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: context.line, width: 1.5),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
