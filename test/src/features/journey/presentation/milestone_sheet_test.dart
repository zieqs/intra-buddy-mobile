import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/milestone_sheet.dart';

import '../journey_fixtures.dart';

Future<void> _open(
  WidgetTester tester,
  JourneyNode node,
  void Function(MilestoneAction?) capture,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              capture(await showMilestoneSheet(context, node: node));
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('open milestone offers Mark done', (tester) async {
    MilestoneAction? action;
    await _open(
      tester,
      journeyNode(
        kind: JourneyNodeKind.milestone,
        title: 'Mid-term report',
        state: JourneyNodeState.open,
        weekNumber: null,
        due: DateTime(2026, 12, 15),
      ),
      (value) => action = value,
    );

    expect(find.text('Mid-term report'), findsOneWidget);
    expect(find.text('Mark done'), findsOneWidget);
    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    expect(action, MilestoneAction.complete);
  });

  testWidgets('done milestone offers Undo completion', (tester) async {
    MilestoneAction? action;
    await _open(
      tester,
      journeyNode(
        kind: JourneyNodeKind.milestone,
        title: 'Attend briefing',
        state: JourneyNodeState.done,
        weekNumber: null,
        completed: true,
      ),
      (value) => action = value,
    );

    expect(find.text('Undo completion'), findsOneWidget);
    await tester.tap(find.text('Undo completion'));
    await tester.pumpAndSettle();
    expect(action, MilestoneAction.undo);
  });

  testWidgets('locked milestone explains itself', (tester) async {
    await _open(
      tester,
      journeyNode(
        kind: JourneyNodeKind.milestone,
        title: 'Final report',
        state: JourneyNodeState.locked,
        weekNumber: null,
      ),
      (_) {},
    );

    expect(find.textContaining('opens later'), findsOneWidget);
    expect(find.text('Mark done'), findsNothing);
  });
}
