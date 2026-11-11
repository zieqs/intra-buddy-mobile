import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/domain/entities/enrollment.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/presentation/widgets/semester_card.dart';

Enrollment _enrollment() {
  return Enrollment(
    semesterId: 2,
    name: 'INTRA Session 2 2026/2027',
    startDate: DateTime(2027, 2, 8),
    endDate: DateTime(2027, 6, 14),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('shows the session name and date range', (tester) async {
    await _pump(tester, SemesterCard(enrollment: _enrollment()));

    expect(find.text('INTRA Session 2 2026/2027'), findsOneWidget);
    expect(find.text('8 Feb 2027 – 14 Jun 2027'), findsOneWidget);
  });

  testWidgets('explains when no session is assigned', (tester) async {
    await _pump(tester, const SemesterCard());

    expect(find.text('No session assigned'), findsOneWidget);
  });

  testWidgets('shows an error instead of claiming no session is assigned', (
    tester,
  ) async {
    await _pump(tester, const SemesterCard(error: true));

    expect(find.text("Couldn't load your session"), findsOneWidget);
    expect(find.text('No session assigned'), findsNothing);
  });

  testWidgets('shows an optional warning under the caption', (tester) async {
    await _pump(
      tester,
      SemesterCard(
        enrollment: _enrollment(),
        caption: "You'll be enrolled in this session automatically.",
        warning:
            'Not your INTRA session? Contact your coordinator before you sign up.',
      ),
    );

    expect(
      find.text("You'll be enrolled in this session automatically."),
      findsOneWidget,
    );
    expect(find.textContaining('Not your INTRA session?'), findsOneWidget);
  });

  testWidgets('shows the contact action only when provided', (tester) async {
    await _pump(tester, SemesterCard(enrollment: _enrollment()));
    expect(find.text('Contact coordinator'), findsNothing);

    await _pump(
      tester,
      SemesterCard(enrollment: _enrollment(), onContact: () {}),
    );
    expect(find.text('Contact coordinator'), findsOneWidget);
  });
}
