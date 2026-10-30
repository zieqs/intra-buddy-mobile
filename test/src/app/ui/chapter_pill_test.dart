import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/chapter_pill.dart';

void main() {
  testWidgets('shows the chapter, count and reports a tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChapterPill(
            title: 'Getting ready',
            done: 4,
            total: 4,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('GETTING READY'), findsOneWidget);
    expect(find.text('4 / 4'), findsOneWidget);
    await tester.tap(find.text('GETTING READY'));
    expect(taps, 1);
  });

  testWidgets('wraps a long chapter title at 2x text scale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: ChapterPill(
                title: 'Getting ready for the placement',
                done: 0,
                total: 4,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.text('GETTING READY FOR THE PLACEMENT')).height,
      greaterThan(30),
    );
  });
}
