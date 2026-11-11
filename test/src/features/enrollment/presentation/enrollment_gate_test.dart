import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/domain/entities/enrollment.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/presentation/enrollment_gate.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/presentation/providers/enrollment_provider.dart';

Enrollment _enrollment() {
  return Enrollment(
    semesterId: 2,
    name: 'INTRA Session 2 2026/2027',
    startDate: DateTime(2027, 2, 8),
    endDate: DateTime(2027, 6, 14),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Future<Enrollment?> Function() load,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [currentEnrollmentProvider.overrideWith((ref) => load())],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const EnrollmentGate(child: Text('the app')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the app when the student is enrolled', (tester) async {
    await _pump(tester, () async => _enrollment());

    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('shows the pending screen when there is no enrollment', (
    tester,
  ) async {
    await _pump(tester, () async => null);

    expect(find.text('the app'), findsNothing);
    expect(find.text("You're not enrolled yet"), findsOneWidget);
    expect(find.text('REFRESH'), findsOneWidget);
  });

  testWidgets('offers a retry when the enrollment lookup fails', (
    tester,
  ) async {
    await _pump(tester, () async => throw Exception('offline'));

    expect(find.text('the app'), findsNothing);
    expect(find.text("We couldn't check your enrollment"), findsOneWidget);
    expect(find.text('REFRESH'), findsOneWidget);
  });
}
