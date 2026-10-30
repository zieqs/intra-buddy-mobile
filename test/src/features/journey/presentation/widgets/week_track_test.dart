import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/week_track.dart';

import '../../journey_fixtures.dart';

void main() {
  testWidgets('shows each week and reports taps', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WeekTrack(
            weeks: [
              journeyNode(id: 'w1', weekNumber: 1, state: JourneyNodeState.done, completed: true),
              journeyNode(id: 'w2', weekNumber: 2, state: JourneyNodeState.current),
              journeyNode(id: 'w3', weekNumber: 3, state: JourneyNodeState.open),
            ],
            onTap: (node) => tapped = node.weekNumber,
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(
      tester.getSize(find.byType(InkWell).first).width,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.text('2'));
    expect(tapped, 2);
  });
}
