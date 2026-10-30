import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/streak_badge.dart';

void main() {
  testWidgets('reads the streak', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: StreakBadge(streak: 6)),
      ),
    );
    expect(find.text('6-week streak'), findsOneWidget);
  });

  testWidgets('starts at zero', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: StreakBadge(streak: 0)),
      ),
    );
    expect(find.text('Start a streak'), findsOneWidget);
  });

  testWidgets('compact mode shows 0 instead of the call to action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreakBadge(streak: 0, compact: true)),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Start a streak'), findsNothing);
  });
}
