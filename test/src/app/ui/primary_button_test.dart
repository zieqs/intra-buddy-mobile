import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/primary_button.dart';

void main() {
  testWidgets('taps and keeps a 48px target', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PrimaryButton(label: 'Mark submitted', onPressed: () => taps++),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(PrimaryButton)).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.text('Mark submitted'));
    expect(taps, 1);
  });

  testWidgets('does nothing when disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: PrimaryButton(label: 'Mark submitted', onPressed: null),
        ),
      ),
    );
    await tester.tap(find.text('Mark submitted'));
    expect(taps, 0);
  });
}
