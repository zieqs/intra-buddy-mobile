import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadii {
  AppRadii._();

  static const double card = 20;
  static const double node = 999;
  static const double button = 14;
  static const double sheet = 24;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D0F2A4A), offset: Offset(0, 5)),
  ];

  static const List<BoxShadow> blueButton = [
    BoxShadow(color: Color(0x1A1D4ED8), offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> sunButton = [
    BoxShadow(color: Color(0x1AD99A16), offset: Offset(0, 5)),
  ];
}

class AppDurations {
  AppDurations._();

  static const Duration quick = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration celebration = Duration(milliseconds: 900);
}
