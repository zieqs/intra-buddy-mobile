import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/trail_node.dart';

import '../../journey_fixtures.dart';

void main() {
  testWidgets('week node reads its number and state', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TrailNode(
            node: journeyNode(),
            isNext: true,
            now: DateTime(2026, 10, 31),
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Week 7'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('UP NEXT'), findsOneWidget);
    await tester.tap(find.text('Week 7'));
    expect(taps, 1);
  });

  testWidgets('done milestone shows Done', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TrailNode(
            node: journeyNode(
              id: 'm1',
              kind: JourneyNodeKind.milestone,
              title: 'Mid-term report',
              state: JourneyNodeState.done,
              weekNumber: null,
              completed: true,
            ),
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Mid-term report'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('missed node is labelled Missed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TrailNode(
            node: journeyNode(state: JourneyNodeState.missed),
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Missed'), findsOneWidget);
  });

  testWidgets('does not overflow at 2x text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: TrailNode(
                node: journeyNode(
                  kind: JourneyNodeKind.milestone,
                  title: 'Submit the supervisor confirmation form',
                  state: JourneyNodeState.open,
                  weekNumber: null,
                  due: DateTime(2026, 11, 6),
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(find.text('Submit the supervisor confirmation form'))
          .height,
      greaterThan(60),
    );
  });
}
