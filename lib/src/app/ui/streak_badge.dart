import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak, this.compact = false});

  final int streak;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = streak == 0 ? 'Start a streak' : '$streak-week streak';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadii.node),
        border: Border.all(color: context.line, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 15,
            color: AppColors.flame,
          ),
          const SizedBox(width: 4),
          Text(
            compact ? '$streak' : label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.ink,
            ),
          ),
        ],
      ),
    );
  }
}
