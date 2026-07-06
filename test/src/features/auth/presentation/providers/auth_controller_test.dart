import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/auth/presentation/providers/auth_controller.dart';

void main() {
  group('mapAuthError', () {
    test('maps "User already registered" to friendly message', () {
      final result = AuthController.mapAuthError('User already registered');
      expect(result, 'An account with this email already exists. Try signing in.');
    });

    test('maps "Unable to validate email" to friendly message', () {
      final result = AuthController.mapAuthError('Unable to validate email');
      expect(result, 'Please enter a valid @s.unikl.edu.my email');
    });

    test('passes through unknown errors', () {
      final result = AuthController.mapAuthError('Some unknown error');
      expect(result, 'Something went wrong. Please try again.');
    });
  });
}
