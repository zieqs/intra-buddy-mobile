import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/build_journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/widgets/your_journey_view.dart';

import '../journey_fixtures.dart';

void main() {
  testWidgets('shows all three chapters and the journey progress', (
    tester,
  ) async {
    final journey = buildJourney(
      checklist: [
        journeyItem(id: 1, title: 'Attend briefing', phase: 'before'),
        journeyItem(id: 2, title: 'Final report', phase: 'after'),
      ],
      weeks: List.generate(12, (index) {
        final week = index + 1;
        return journeyWeek(
          week,
          DateTime(2026, 9, 18).add(Duration(days: 7 * week)),
        );
      }),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: YourJourneyView(
          journey: journey,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onNodeTap: (_) {},
          onProfile: () {},
          onBack: () {},
          now: DateTime(2026, 10, 31),
        ),
      ),
    );

    expect(find.text('GETTING READY'), findsOneWidget);
    expect(find.text('THE INTERNSHIP'), findsOneWidget);
    expect(find.text('WRAPPING UP'), findsOneWidget);
    expect(find.textContaining('Journey progress'), findsOneWidget);
  });
}
