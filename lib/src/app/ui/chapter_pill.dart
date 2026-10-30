import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class ChapterPill extends StatelessWidget {
  const ChapterPill({
    super.key,
    required this.title,
    required this.done,
    required this.total,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final int done;
  final int total;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final dotColor = locked
        ? context.lineStrong
        : done >= total && total > 0
        ? context.blue
        : context.sun;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.node),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: locked ? context.ice : context.card,
          borderRadius: BorderRadius.circular(AppRadii.node),
          border: Border.all(
            color: locked ? context.lineStrong : context.line,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: locked ? context.muted : context.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              locked ? 'Locked' : '$done / $total',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: locked ? context.muted : context.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
