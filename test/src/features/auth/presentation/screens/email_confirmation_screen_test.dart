import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/auth/presentation/screens/email_confirmation_screen.dart';

void main() {
  group('EmailConfirmationScreen', () {
    testWidgets('shows email address', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmailConfirmationScreen(email: 'test@s.unikl.edu.my'),
        ),
      );

      expect(find.text('test@s.unikl.edu.my'), findsOneWidget);
    });

    testWidgets('shows verify your email heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmailConfirmationScreen(email: 'test@s.unikl.edu.my'),
        ),
      );

      expect(find.text('Verify Your Email'), findsOneWidget);
    });

    testWidgets('shows Open Mail App button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmailConfirmationScreen(email: 'test@s.unikl.edu.my'),
        ),
      );

      expect(find.text('OPEN MAIL APP'), findsOneWidget);
    });

    testWidgets('shows Back to Login button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmailConfirmationScreen(email: 'test@s.unikl.edu.my'),
        ),
      );

      expect(find.text('BACK TO LOGIN'), findsOneWidget);
    });
  });
}
