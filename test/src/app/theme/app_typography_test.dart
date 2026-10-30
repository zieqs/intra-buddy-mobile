import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_typography.dart';

void main() {
  final t = AppTypography.textTheme;

  test('display styles are Fredoka', () {
    for (final style in [
      t.displayLarge!,
      t.headlineLarge!,
      t.headlineMedium!,
      t.titleLarge!,
    ]) {
      expect(style.fontFamily, 'Fredoka');
    }
    expect(t.titleLarge!.fontSize, greaterThanOrEqualTo(18));
  });

  test('functional styles are Nunito', () {
    expect(t.bodyLarge?.fontFamily, 'Nunito');
    expect(t.bodyMedium?.fontFamily, 'Nunito');
    expect(t.labelLarge?.fontFamily, 'Nunito');
  });

  test('body copy never drops below 13px', () {
    expect(t.bodyLarge!.fontSize, greaterThanOrEqualTo(13));
    expect(t.bodyMedium!.fontSize, greaterThanOrEqualTo(13));
  });

  test('labels carry wide tracking', () {
    expect(t.labelLarge?.letterSpacing, closeTo(1.4, 0.01));
  });
}
