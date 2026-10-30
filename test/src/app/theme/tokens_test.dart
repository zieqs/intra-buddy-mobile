import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_colors.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/tokens.dart';

double _contrast(Color a, Color b) {
  final hi = math.max(a.computeLuminance(), b.computeLuminance());
  final lo = math.min(a.computeLuminance(), b.computeLuminance());
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('blue palette', () {
    expect(AppColors.page.toARGB32(), 0xFFF4F8FF);
    expect(AppColors.white.toARGB32(), 0xFFFFFFFF);
    expect(AppColors.ice.toARGB32(), 0xFFE7F0FF);
    expect(AppColors.blue.toARGB32(), 0xFF2563EB);
    expect(AppColors.blueDeep.toARGB32(), 0xFF1D4ED8);
    expect(AppColors.sky.toARGB32(), 0xFF60A5FA);
    expect(AppColors.ink.toARGB32(), 0xFF0F2A4A);
    expect(AppColors.muted.toARGB32(), 0xFF5C6F86);
    expect(AppColors.sun.toARGB32(), 0xFFFFC53D);
    expect(AppColors.sunText.toARGB32(), 0xFF5C4300);
    expect(AppColors.alert.toARGB32(), 0xFFE5484D);
  });

  test('key pairs meet 4.5:1', () {
    expect(
      _contrast(AppColors.white, AppColors.blue),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(AppColors.ink, AppColors.page),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(AppColors.muted, AppColors.page),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(AppColors.sunText, AppColors.sun),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('spacing, radii and durations', () {
    expect(AppSpacing.lg, 16);
    expect(AppRadii.card, 20);
    expect(AppRadii.button, 14);
    expect(AppDurations.standard, const Duration(milliseconds: 220));
    expect(AppDurations.celebration, const Duration(milliseconds: 900));
  });

  testWidgets('semantic colours resolve', (tester) async {
    late Color page;
    late Color blue;
    late Color ink;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (context) {
            page = context.page;
            blue = context.blue;
            ink = context.ink;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(page, AppColors.page);
    expect(blue, AppColors.blue);
    expect(ink, AppColors.ink);
  });
}
