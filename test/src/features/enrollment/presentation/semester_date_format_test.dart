import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/presentation/semester_date_format.dart';

void main() {
  group('formatSemesterDate', () {
    test('formats a date without leading zeroes', () {
      expect(formatSemesterDate(DateTime(2027, 2, 8)), '8 Feb 2027');
    });
  });

  group('formatSemesterRange', () {
    test('joins the start and end dates', () {
      expect(
        formatSemesterRange(DateTime(2027, 2, 8), DateTime(2027, 6, 14)),
        '8 Feb 2027 – 14 Jun 2027',
      );
    });
  });
}
