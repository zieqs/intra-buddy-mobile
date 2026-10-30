import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_colors.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';

void main() {
  test('light theme paints the blue trail', () {
    final theme = AppTheme.light;
    expect(theme.scaffoldBackgroundColor, AppColors.page);
    expect(theme.colorScheme.primary, AppColors.blue);
    expect(theme.colorScheme.onPrimary, AppColors.white);
    expect(theme.colorScheme.surface, AppColors.page);
    expect(theme.colorScheme.onSurface, AppColors.ink);
    expect(theme.cardTheme.color, AppColors.white);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Nunito');
  });
}
