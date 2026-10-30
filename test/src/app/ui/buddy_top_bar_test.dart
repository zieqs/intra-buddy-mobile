import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/buddy_top_bar.dart';

void main() {
  testWidgets('shows brand, streak and a labelled profile action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var profiles = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BuddyTopBar(
            brand: 'INTRA BUDDY',
            streak: 6,
            userName: 'Aisyah',
            bell: const SizedBox(),
            onProfile: () => profiles++,
          ),
        ),
      ),
    );

    expect(find.text('INTRA'), findsOneWidget);
    expect(find.text('BUDDY'), findsOneWidget);
    expect(find.textContaining('6-week streak'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Profile'));
    expect(profiles, 1);
    semantics.dispose();
  });

  testWidgets('shows a back arrow on pushed screens', (tester) async {
    var backs = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BuddyTopBar(
            brand: 'YOUR JOURNEY',
            streak: 6,
            userName: 'Aisyah',
            bell: const SizedBox(),
            onProfile: () {},
            onBack: () => backs++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    expect(backs, 1);
  });
}
