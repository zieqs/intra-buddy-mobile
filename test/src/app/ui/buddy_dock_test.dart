import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/buddy_dock.dart';

void main() {
  testWidgets('shows four labelled tabs and reports selection', (tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BuddyDock(
            currentIndex: 0,
            onSelected: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Logbook'), findsOneWidget);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);
    await tester.tap(find.text('Jobs'));
    expect(selected, 2);
  });

  testWidgets('stays compact in the scaffold bottom bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: const Text('Page'),
          bottomNavigationBar: BuddyDock(currentIndex: 0, onSelected: (_) {}),
        ),
      ),
    );

    expect(tester.getSize(find.byType(BuddyDock)).height, lessThan(100));
    expect(find.text('Page'), findsOneWidget);
  });

  testWidgets('labels stay inside a phone-width dock at 2x text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 320,
                child: BuddyDock(currentIndex: 0, onSelected: (_) {}),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Logbook'), findsOneWidget);
  });
}
