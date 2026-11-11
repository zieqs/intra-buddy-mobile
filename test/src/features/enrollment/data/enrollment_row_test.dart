import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/data/enrollment_remote_datasource.dart';

void main() {
  group('enrollmentFromRow', () {
    test('maps a semester row', () {
      final enrollment = enrollmentFromRow({
        'id': 7,
        'name': 'INTRA Session 1 2026/2027',
        'start_date': '2026-09-27',
        'end_date': '2027-01-31',
        'is_active': true,
      });

      expect(enrollment.semesterId, 7);
      expect(enrollment.name, 'INTRA Session 1 2026/2027');
      expect(enrollment.startDate, DateTime(2026, 9, 27));
      expect(enrollment.endDate, DateTime(2027, 1, 31));
      expect(enrollment.isActive, isTrue);
    });

    test('treats a missing is_active as not active', () {
      final enrollment = enrollmentFromRow({
        'id': 8,
        'name': 'INTRA Session 2 2026/2027',
        'start_date': '2027-02-08',
        'end_date': '2027-06-14',
      });

      expect(enrollment.isActive, isFalse);
    });
  });
}
