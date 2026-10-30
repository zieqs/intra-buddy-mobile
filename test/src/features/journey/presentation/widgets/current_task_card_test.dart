import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/current_task_card.dart';

import '../../journey_fixtures.dart';

void main() {
  testWidgets('shows the next task and reports the action', (tester) async {
    var acted = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CurrentTaskCard(
            node: journeyNode(),
            dueLabel: 'Due Friday',
            actionLabel: 'Mark submitted',
            onAction: () => acted++,
          ),
        ),
      ),
    );

    expect(find.text('Week 7'), findsOneWidget);
    expect(find.text('Due Friday'), findsOneWidget);
    await tester.tap(find.text('Mark submitted'));
    expect(acted, 1);
  });

  testWidgets('wraps a long title at 2x text scale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: CurrentTaskCard(
                node: journeyNode(
                  kind: JourneyNodeKind.milestone,
                  title:
                      'Submit the supervisor confirmation and final evaluation form',
                  weekNumber: null,
                ),
                  actionLabel: 'Mark done',
                  onAction: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(
            find.text(
              'Submit the supervisor confirmation and final evaluation form',
            ),
          )
          .height,
      greaterThan(100),
    );
  });
}
