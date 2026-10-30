import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/celebration_overlay.dart';

void main() {
  testWidgets('shows the headline, streak and continue action', (tester) async {
    var continued = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CelebrationOverlay(
          headline: 'Week 7 done!',
          subline: '5 to go',
          streak: 6,
          progress: 0.58,
          progressLabel: '10 of 18 done',
          onContinue: () => continued++,
        ),
      ),
    );

    expect(find.textContaining('Week 7'), findsOneWidget);
    expect(find.textContaining('6-week streak'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('celebration-confetti')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep going'));
    expect(continued, 1);
  });

  testWidgets('reduced motion still shows the result', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CelebrationOverlay(
            headline: 'Week 7 done!',
            subline: '5 to go',
            streak: 6,
            progress: 0.58,
            progressLabel: '10 of 18 done',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Week 7'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('celebration-confetti')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
