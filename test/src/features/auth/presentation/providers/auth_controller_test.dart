import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/auth/presentation/providers/auth_controller.dart';

void main() {
  group('mapAuthError', () {
    test('maps "User already registered" to friendly message', () {
      final result = AuthController.mapAuthError('User already registered');
      expect(
        result,
        'An account with this email already exists. Try signing in.',
      );
    });

    test('maps "Unable to validate email" to friendly message', () {
      final result = AuthController.mapAuthError('Unable to validate email');
      expect(result, 'Please enter a valid @s.unikl.edu.my email');
    });

    test('maps wrong credentials to a specific message', () {
      final result = AuthController.mapAuthError('Invalid login credentials');
      expect(result, 'Incorrect email or password. Please try again.');
    });

    test('maps an unconfirmed email to a specific message', () {
      final result = AuthController.mapAuthError('Email not confirmed');
      expect(
        result,
        'Please confirm your email before signing in. Check your inbox.',
      );
    });

    test('maps auth rate limiting to a specific message', () {
      final result = AuthController.mapAuthError(
        'For security purposes, you can only request this after 42 seconds.',
      );
      expect(result, 'Too many attempts. Please wait a moment and try again.');
    });

    test('is case-insensitive', () {
      final result = AuthController.mapAuthError('EMAIL NOT CONFIRMED');
      expect(
        result,
        'Please confirm your email before signing in. Check your inbox.',
      );
    });

    test('passes through unknown errors', () {
      final result = AuthController.mapAuthError('Some unknown error');
      expect(result, 'Something went wrong. Please try again.');
    });
  });
}
