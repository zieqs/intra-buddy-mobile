import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: AppColors.blue,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.blueWash,
      onPrimaryContainer: AppColors.blue,
      secondary: AppColors.sky,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.blueWash,
      onSecondaryContainer: AppColors.blue,
      tertiary: AppColors.sun,
      onTertiary: AppColors.sunText,
      tertiaryContainer: AppColors.sunWash,
      onTertiaryContainer: AppColors.sunText,
      error: AppColors.alert,
      onError: AppColors.white,
      errorContainer: AppColors.alertWash,
      onErrorContainer: AppColors.alert,
      surface: AppColors.page,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.line,
    ),
    page: AppColors.page,
    card: AppColors.white,
    ice: AppColors.ice,
    ink: AppColors.ink,
    muted: AppColors.muted,
    line: AppColors.line,
    sun: AppColors.sun,
    sunText: AppColors.sunText,
    stage: AppColors.ink,
    onStage: AppColors.white,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: AppColors.darkBlue,
      onPrimary: AppColors.darkPage,
      primaryContainer: AppColors.darkBlueWash,
      onPrimaryContainer: AppColors.darkInk,
      secondary: AppColors.sky,
      onSecondary: AppColors.darkInk,
      secondaryContainer: AppColors.darkBlueWash,
      onSecondaryContainer: AppColors.darkInk,
      tertiary: AppColors.darkSun,
      onTertiary: AppColors.sunText,
      tertiaryContainer: AppColors.darkSunWash,
      onTertiaryContainer: AppColors.darkSun,
      error: AppColors.darkAlert,
      onError: AppColors.darkPage,
      errorContainer: AppColors.darkAlertWash,
      onErrorContainer: AppColors.darkAlert,
      surface: AppColors.darkPage,
      onSurface: AppColors.darkInk,
      onSurfaceVariant: AppColors.darkMuted,
      outline: AppColors.darkLine,
    ),
    page: AppColors.darkPage,
    card: AppColors.darkCard,
    ice: AppColors.darkIce,
    ink: AppColors.darkInk,
    muted: AppColors.darkMuted,
    line: AppColors.darkLine,
    sun: AppColors.darkSun,
    sunText: AppColors.sunText,
    stage: AppColors.darkCard,
    onStage: AppColors.darkInk,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color page,
    required Color card,
    required Color ice,
    required Color ink,
    required Color muted,
    required Color line,
    required Color sun,
    required Color sunText,
    required Color stage,
    required Color onStage,
  }) {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: ink,
      displayColor: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: ink, size: 20),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: page,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: ink),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: line, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          textStyle: textTheme.titleMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide(color: line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide(color: line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? scheme.primary : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.blueWash
              : ice,
        ),
      ),
      /* Temporary until BuddyDock lands. */
      navigationBarTheme: NavigationBarThemeData(
        height: 58,
        backgroundColor: card,
        indicatorColor: AppColors.blueWash,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
            size: 22,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ice,
        selectedColor: AppColors.blueWash,
        labelStyle: textTheme.labelSmall?.copyWith(color: ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.node),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: stage,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onStage),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium?.copyWith(color: ink),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
    );
  }
}
