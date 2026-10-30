import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'streak_badge.dart';

class BuddyTopBar extends StatelessWidget {
  const BuddyTopBar({
    super.key,
    required this.brand,
    required this.streak,
    required this.userName,
    required this.bell,
    required this.onProfile,
    this.onBack,
    this.onStreakTap,
  });

  final String brand;
  final int streak;
  final String userName;
  final Widget bell;
  final VoidCallback onProfile;
  final VoidCallback? onBack;
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    final parts = brand.split(' ');
    final first = parts.first;
    final rest = parts.skip(1).join(' ');
    final trimmed = userName.trim();
    final initial = trimmed.isEmpty ? 'S' : trimmed[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                color: context.ink,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (rest.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      rest,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          if (onStreakTap != null)
            Semantics(
              button: true,
              label: 'Open logbook',
              child: InkWell(
                onTap: onStreakTap,
                borderRadius: BorderRadius.circular(AppRadii.node),
                child: StreakBadge(streak: streak, compact: true),
              ),
            )
          else
            StreakBadge(streak: streak, compact: true),
          const SizedBox(width: 2),
          bell,
          const SizedBox(width: 2),
          Semantics(
            button: true,
            label: 'Profile',
            onTap: onProfile,
            excludeSemantics: true,
            child: InkWell(
              onTap: onProfile,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.ice,
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
