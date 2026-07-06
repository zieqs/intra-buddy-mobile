import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Constant accent colors (same in light & dark) ---
  static const primary = Color(0xFF1D4ED8);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF0D9488);
  static const onSecondary = Color(0xFFFFFFFF);
  static const tertiary = Color(0xFFF59E0B);
  static const onTertiary = Color(0xFF1E293B);
  static const error = Color(0xFFEF4444);
  static const onError = Color(0xFFFFFFFF);

  // --- Light theme ---
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightOnBackground = Color(0xFF302F2C);
  static const lightSurface = Color(0xFFFAFAFA);
  static const lightOnSurface = Color(0xFF302F2C);
  static const lightOutline = Color(0xFFE2E8F0);
  static const lightMuted = Color(0xFF64748B);
  static const lightPrimaryContainer = Color(0xFFDBEAFE);
  static const lightOnPrimaryContainer = Color(0xFF1E3A5F);
  static const lightSecondaryContainer = Color(0xFFCCFBF1);
  static const lightOnSecondaryContainer = Color(0xFF134E4A);
  static const lightTertiaryContainer = Color(0xFFFEF3C7);
  static const lightOnTertiaryContainer = Color(0xFF78350F);
  static const lightErrorContainer = Color(0xFFFEE2E2);
  static const lightOnErrorContainer = Color(0xFF7F1D1D);

  // --- Dark theme ---
  static const darkBackground = Color(0xFF1C1C1C);
  static const darkOnBackground = Color(0xFFFAFAFA);
  static const darkSurface = Color(0xFF2A2A2A);
  static const darkOnSurface = Color(0xFFFAFAFA);
  static const darkOutline = Color(0xFF3A3A3A);
  static const darkMuted = Color(0xFF9E9E9E);
  static const darkPrimaryContainer = Color(0xFF1E3A5F);
  static const darkOnPrimaryContainer = Color(0xFFDBEAFE);
  static const darkSecondaryContainer = Color(0xFF134E4A);
  static const darkOnSecondaryContainer = Color(0xFFCCFBF1);
  static const darkTertiaryContainer = Color(0xFF78350F);
  static const darkOnTertiaryContainer = Color(0xFFFEF3C7);
  static const darkErrorContainer = Color(0xFF7F1D1D);
  static const darkOnErrorContainer = Color(0xFFFEE2E2);
}

extension ThemeColor on BuildContext {
  Color _resolve(Color light, Color dark) =>
      brightness == Brightness.dark ? dark : light;

  Brightness get brightness => Theme.of(this).brightness;

  Color get background =>
      _resolve(AppColors.lightBackground, AppColors.darkBackground);
  Color get onBackground =>
      _resolve(AppColors.lightOnBackground, AppColors.darkOnBackground);
  Color get surface => _resolve(AppColors.lightSurface, AppColors.darkSurface);
  Color get onSurface =>
      _resolve(AppColors.lightOnSurface, AppColors.darkOnSurface);
  Color get outline => _resolve(AppColors.lightOutline, AppColors.darkOutline);
  Color get muted => _resolve(AppColors.lightMuted, AppColors.darkMuted);
  Color get primaryContainer =>
      _resolve(AppColors.lightPrimaryContainer, AppColors.darkPrimaryContainer);
  Color get onPrimaryContainer => _resolve(
    AppColors.lightOnPrimaryContainer,
    AppColors.darkOnPrimaryContainer,
  );
  Color get secondaryContainer => _resolve(
    AppColors.lightSecondaryContainer,
    AppColors.darkSecondaryContainer,
  );
  Color get onSecondaryContainer => _resolve(
    AppColors.lightOnSecondaryContainer,
    AppColors.darkOnSecondaryContainer,
  );
  Color get tertiaryContainer => _resolve(
    AppColors.lightTertiaryContainer,
    AppColors.darkTertiaryContainer,
  );
  Color get onTertiaryContainer => _resolve(
    AppColors.lightOnTertiaryContainer,
    AppColors.darkOnTertiaryContainer,
  );
  Color get errorContainer =>
      _resolve(AppColors.lightErrorContainer, AppColors.darkErrorContainer);
  Color get onErrorContainer =>
      _resolve(AppColors.lightOnErrorContainer, AppColors.darkOnErrorContainer);
}
