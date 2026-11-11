import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/utils/coordinator_contact.dart';

void main() {
  group('parseCoordinatorContact', () {
    test('turns an email address into a mailto link', () {
      expect(
        parseCoordinatorContact('coordinator@unikl.edu.my').toString(),
        'mailto:coordinator@unikl.edu.my',
      );
    });

    test('keeps an explicit URL', () {
      expect(
        parseCoordinatorContact('https://wa.me/60123456789').toString(),
        'https://wa.me/60123456789',
      );
    });

    test('turns a phone number into a WhatsApp link', () {
      expect(
        parseCoordinatorContact('+60 12-345 6789').toString(),
        'https://wa.me/60123456789',
      );
    });

    test('returns null when no contact is configured', () {
      expect(parseCoordinatorContact(null), isNull);
      expect(parseCoordinatorContact('   '), isNull);
    });
  });
}
