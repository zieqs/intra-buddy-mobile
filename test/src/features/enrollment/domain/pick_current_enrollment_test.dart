import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/domain/entities/enrollment.dart';
import 'package:intra_buddy_mobile_v2/src/features/enrollment/domain/pick_current_enrollment.dart';

Enrollment _semester(
  int id, {
  required DateTime start,
  required DateTime end,
  bool isActive = false,
}) {
  return Enrollment(
    semesterId: id,
    name: 'Semester $id',
    startDate: start,
    endDate: end,
    isActive: isActive,
  );
}

void main() {
  group('pickCurrentEnrollment', () {
    test('returns null when the student has no enrollments', () {
      expect(pickCurrentEnrollment(const [], DateTime(2026, 12, 1)), isNull);
    });

    test('picks the semester whose dates contain today', () {
      final result = pickCurrentEnrollment([
        _semester(1, start: DateTime(2026, 2, 1), end: DateTime(2026, 6, 30)),
        _semester(
          2,
          start: DateTime(2026, 9, 27),
          end: DateTime(2027, 1, 31),
          isActive: true,
        ),
      ], DateTime(2026, 12, 1));

      expect(result?.semesterId, 2);
    });

    test('prefers the active semester when two contain today', () {
      final result = pickCurrentEnrollment([
        _semester(1, start: DateTime(2026, 9, 1), end: DateTime(2027, 1, 31)),
        _semester(
          2,
          start: DateTime(2026, 10, 1),
          end: DateTime(2027, 2, 28),
          isActive: true,
        ),
      ], DateTime(2026, 12, 1));

      expect(result?.semesterId, 2);
    });

    test('falls back to the active semester between sessions', () {
      final result = pickCurrentEnrollment([
        _semester(1, start: DateTime(2026, 2, 1), end: DateTime(2026, 6, 30)),
        _semester(
          2,
          start: DateTime(2026, 9, 27),
          end: DateTime(2027, 1, 31),
          isActive: true,
        ),
      ], DateTime(2026, 8, 1));

      expect(result?.semesterId, 2);
    });

    test('falls back to the most recently started semester', () {
      final result = pickCurrentEnrollment([
        _semester(1, start: DateTime(2026, 2, 1), end: DateTime(2026, 6, 30)),
        _semester(2, start: DateTime(2027, 2, 8), end: DateTime(2027, 6, 14)),
      ], DateTime(2026, 12, 1));

      expect(result?.semesterId, 2);
    });

    test('does not break when an older semester is still marked active', () {
      final result = pickCurrentEnrollment([
        _semester(
          1,
          start: DateTime(2025, 9, 1),
          end: DateTime(2026, 1, 31),
          isActive: true,
        ),
        _semester(2, start: DateTime(2026, 2, 8), end: DateTime(2026, 6, 14)),
      ], DateTime(2026, 3, 1));

      expect(result?.semesterId, 2);
    });
  });
}
