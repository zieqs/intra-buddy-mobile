import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/auth/presentation/screens/signup_screen.dart';

void main() {
  group('SignupScreen', () {
    testWidgets('shows step 1 initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupScreen()),
        ),
      );

      expect(find.text('About You'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('navigates to step 2 after valid step 1', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupScreen()),
        ),
      );

      // Fill step 1 fields
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), '01234567890');
      await tester.enterText(find.byType(TextFormField).at(2), 'john@s.unikl.edu.my');
      await tester.enterText(find.byType(TextFormField).at(3), '0123456789');

      // Need to trigger validator — tap next
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Secure Your Account'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty step 1', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.tap(find.text('NEXT'));
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('shows Back button on step 2', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupScreen()),
        ),
      );

      // Fill step 1
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), '01234567890');
      await tester.enterText(find.byType(TextFormField).at(2), 'john@s.unikl.edu.my');
      await tester.enterText(find.byType(TextFormField).at(3), '0123456789');
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('navigates back to step 1 from step 2', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), '01234567890');
      await tester.enterText(find.byType(TextFormField).at(2), 'john@s.unikl.edu.my');
      await tester.enterText(find.byType(TextFormField).at(3), '0123456789');
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      expect(find.text('About You'), findsOneWidget);
    });
  });
}
