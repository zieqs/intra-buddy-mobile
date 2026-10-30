import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_week_info.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/widgets/logbook_view.dart';

import '../../journey/journey_fixtures.dart';

void main() {
  testWidgets('shows the current week and allows marking it', (tester) async {
    final weeks = List.generate(12, (index) {
      final number = index + 1;
      final end = DateTime(2026, 9, 18).add(Duration(days: 7 * number));
      return journeyWeek(
        number,
        end,
        submitted: number <= 6,
        submittedAt: number <= 6 ? end : null,
      );
    });
    final summary = buildLogbookSummary(weeks, DateTime(2026, 10, 31));
    LogbookWeekInfo? tapped;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LogbookView(
          summary: summary,
          streak: 6,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onWeekTap: (info) => tapped = info,
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.text('Week 7.'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('ALL WEEKS'), findsOneWidget);
    expect(find.text('Week 6'), findsOneWidget);
    await tester.tap(find.text('Mark submitted'));
    expect(tapped?.week.weekNumber, 7);
  });
}
