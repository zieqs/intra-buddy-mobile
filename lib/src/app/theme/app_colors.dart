import 'package:flutter/material.dart';

/// INTRA Buddy blue trail palette.
///
/// Screens should use the semantic `ThemeColor` getters. The legacy names stay
/// as aliases so untouched screens keep compiling while they are rebuilt.
class AppColors {
  AppColors._();

  static const page = Color(0xFFF4F8FF);
  static const white = Color(0xFFFFFFFF);
  static const ice = Color(0xFFE7F0FF);
  static const blue = Color(0xFF2563EB);
  static const blueDeep = Color(0xFF1D4ED8);
  static const sky = Color(0xFF60A5FA);
  static const ink = Color(0xFF0F2A4A);
  static const muted = Color(0xFF5C6F86);
  static const line = Color(0xFFDCE8FF);
  static const lineStrong = Color(0xFFC9D9F5);
  static const sun = Color(0xFFFFC53D);
  static const sunDeep = Color(0xFFD99A16);
  static const sunText = Color(0xFF5C4300);
  static const flame = Color(0xFFFFB020);
  static const alert = Color(0xFFE5484D);
  static const alertWash = Color(0x1AE5484D);
  static const blueWash = Color(0x1A2563EB);
  static const sunWash = Color(0x1AFFC53D);

  // Dark mapping. The Light-first phase does not use it yet, but keeping the
  // theme compiling avoids a half-migrated app.
  static const darkPage = Color(0xFF081A33);
  static const darkCard = Color(0xFF102A4A);
  static const darkIce = Color(0xFF0C2240);
  static const darkInk = Color(0xFFF4F8FF);
  static const darkMuted = Color(0xFFA9B8CC);
  static const darkLine = Color(0xFF1E3A5F);
  static const darkBlue = Color(0xFF60A5FA);
  static const darkSun = Color(0xFFFFC53D);
  static const darkAlert = Color(0xFFFF8A8A);
  static const darkAlertWash = Color(0x24FF8A8A);
  static const darkBlueWash = Color(0x2460A5FA);
  static const darkSunWash = Color(0x24FFC53D);

  // Legacy aliases.
  static const primary = blue;
  static const onPrimary = white;
  static const secondary = sky;
  static const onSecondary = ink;
  static const tertiary = sun;
  static const onTertiary = sunText;
  static const error = alert;
  static const onError = white;

  static const lightBackground = page;
  static const lightOnBackground = ink;
  static const lightSurface = white;
  static const lightOnSurface = ink;
  static const lightOutline = line;
  static const lightMuted = muted;
  static const lightPrimaryContainer = blueWash;
  static const lightOnPrimaryContainer = blue;
  static const lightSecondaryContainer = blueWash;
  static const lightOnSecondaryContainer = blue;
  static const lightTertiaryContainer = sunWash;
  static const lightOnTertiaryContainer = sunText;
  static const lightErrorContainer = alertWash;
  static const lightOnErrorContainer = alert;
  static const lightChatThinkingBg = ice;
  static const lightChatThinkingText = muted;

  static const darkBackground = darkPage;
  static const darkOnBackground = darkInk;
  static const darkSurface = darkCard;
  static const darkOnSurface = darkInk;
  static const darkOutline = darkLine;
  static const darkMutedAlias = darkMuted;
  static const darkPrimaryContainer = darkBlueWash;
  static const darkOnPrimaryContainer = darkInk;
  static const darkSecondaryContainer = darkBlueWash;
  static const darkOnSecondaryContainer = darkInk;
  static const darkTertiaryContainer = darkSunWash;
  static const darkOnTertiaryContainer = darkSun;
  static const darkErrorContainer = darkAlertWash;
  static const darkOnErrorContainer = darkAlert;
  static const darkChatThinkingBg = darkIce;
  static const darkChatThinkingText = darkMuted;
}

extension ThemeColor on BuildContext {
  Color _resolve(Color light, Color dark) =>
      brightness == Brightness.dark ? dark : light;

  Brightness get brightness => Theme.of(this).brightness;

  // --- Blue trail semantic tokens ---
  Color get page => _resolve(AppColors.page, AppColors.darkPage);
  Color get card => _resolve(AppColors.white, AppColors.darkCard);
  Color get ice => _resolve(AppColors.ice, AppColors.darkIce);
  Color get blue => _resolve(AppColors.blue, AppColors.darkBlue);
  Color get blueDeep => AppColors.blueDeep;
  Color get sky => AppColors.sky;
  Color get ink => _resolve(AppColors.ink, AppColors.darkInk);
  Color get muted => _resolve(AppColors.muted, AppColors.darkMuted);
  Color get line => _resolve(AppColors.line, AppColors.darkLine);
  Color get lineStrong => AppColors.lineStrong;
  Color get sun => AppColors.sun;
  Color get sunText => AppColors.sunText;
  Color get alert => _resolve(AppColors.alert, AppColors.darkAlert);

  // --- Legacy getters, remapped ---
  Color get background => page;
  Color get onBackground => ink;
  Color get surface => card;
  Color get onSurface => ink;
  Color get outline => line;
  Color get primaryContainer =>
      _resolve(AppColors.blueWash, AppColors.darkBlueWash);
  Color get onPrimaryContainer => blue;
  Color get secondaryContainer =>
      _resolve(AppColors.blueWash, AppColors.darkBlueWash);
  Color get onSecondaryContainer => blue;
  Color get tertiaryContainer =>
      _resolve(AppColors.sunWash, AppColors.darkSunWash);
  Color get onTertiaryContainer => sunText;
  Color get errorContainer =>
      _resolve(AppColors.alertWash, AppColors.darkAlertWash);
  Color get onErrorContainer => alert;
  Color get chatThinkingBg => ice;
  Color get chatThinkingText => muted;
}
