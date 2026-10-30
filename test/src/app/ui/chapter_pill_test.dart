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
}
