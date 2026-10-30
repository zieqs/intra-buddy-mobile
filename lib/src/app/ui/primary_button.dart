import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.sun = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool sun;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background = sun ? context.sun : context.blue;
    final foreground = sun ? context.sunText : AppColors.white;
    final shadow = sun ? AppShadows.sunButton : AppShadows.blueButton;

    final button = Container(
      width: expand ? double.infinity : null,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.button),
        boxShadow: enabled ? shadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.button),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!enabled) return Opacity(opacity: 0.4, child: button);
    return button;
  }
}
