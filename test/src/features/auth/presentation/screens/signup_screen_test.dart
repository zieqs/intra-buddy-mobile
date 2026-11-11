import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/domain/entities/enrollment.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/presentation/providers/enrollment_provider.dart';

Enrollment _openSemester() {
  return Enrollment(
    semesterId: 2,
    name: 'INTRA Session 2 2026/2027',
    startDate: DateTime(2027, 2, 8),
    endDate: DateTime(2027, 6, 14),
  );
}

Future<void> _pumpSignup(
  WidgetTester tester, {
  Future<Enrollment?> Function()? openSemester,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        openSemesterProvider.overrideWith(
          (ref) => openSemester?.call() ?? Future.value(_openSemester()),
        ),
      ],
      child: const MaterialApp(home: SignupScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillStep1(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
  await tester.enterText(find.byType(TextFormField).at(1), '01234567890');
  await tester.enterText(
    find.byType(TextFormField).at(2),
    'john@s.unikl.edu.my',
  );
  await tester.enterText(find.byType(TextFormField).at(3), '0123456789');
}

Future<void> _tapNext(WidgetTester tester) async {
  await tester.ensureVisible(find.text('NEXT'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('NEXT'));
  await tester.pumpAndSettle();
}

void main() {
  group('SignupScreen', () {
    testWidgets('shows the session the student is registering for', (
      tester,
    ) async {
      await _pumpSignup(tester);

      expect(find.text('Registering for'), findsOneWidget);
      expect(find.text('INTRA Session 2 2026/2027'), findsOneWidget);
      expect(find.text('8 Feb 2027 – 14 Jun 2027'), findsOneWidget);
    });

    testWidgets('blocks signup when no session is open for registration', (
      tester,
    ) async {
      await _pumpSignup(tester, openSemester: () async => null);

      expect(find.text('No session open for registration'), findsOneWidget);
      final next = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'NEXT'),
      );
      expect(next.onPressed, isNull);

      await _fillStep1(tester);
      await _tapNext(tester);

      expect(find.text('Secure Your Account'), findsNothing);
    });

    testWidgets('does not block signup when the lookup fails', (tester) async {
      await _pumpSignup(
        tester,
        openSemester: () async => throw Exception('offline'),
      );

      expect(find.text("Couldn't load your session"), findsOneWidget);
      final next = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'NEXT'),
      );
      expect(next.onPressed, isNotNull);
    });

    testWidgets('shows step 1 initially', (tester) async {
      await _pumpSignup(tester);

      expect(find.text('About You'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('navigates to step 2 after valid step 1', (tester) async {
      await _pumpSignup(tester);

      await _fillStep1(tester);
      await _tapNext(tester);

      expect(find.text('Secure Your Account'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty step 1', (tester) async {
      await _pumpSignup(tester);

      await _tapNext(tester);

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('shows Back button on step 2', (tester) async {
      await _pumpSignup(tester);

      await _fillStep1(tester);
      await _tapNext(tester);

      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('navigates back to step 1 from step 2', (tester) async {
      await _pumpSignup(tester);

      await _fillStep1(tester);
      await _tapNext(tester);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      expect(find.text('About You'), findsOneWidget);
    });
  });
}
