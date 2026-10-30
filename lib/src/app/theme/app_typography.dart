import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  /// Blue trail type scale: Fredoka for display, Nunito for functional text.
  static TextTheme get textTheme {
    final base = Typography.material2021().black.apply(fontFamily: 'Nunito');

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Fredoka',
        fontSize: 34,
        height: 1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Fredoka',
        fontSize: 29,
        height: 1.02,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Fredoka',
        fontSize: 22,
        height: 1.1,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Fredoka',
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 11,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 9,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 8,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}
