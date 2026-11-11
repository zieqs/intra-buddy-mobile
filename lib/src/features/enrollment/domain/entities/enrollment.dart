/// A semester the student is enrolled in.
///
/// `isActive` mirrors `semesters.is_active`, which marks the session that is
/// currently running. It is not the same as "open for registration".
class Enrollment {
  const Enrollment({
    required this.semesterId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
  });

  final int semesterId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  bool contains(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }
}
