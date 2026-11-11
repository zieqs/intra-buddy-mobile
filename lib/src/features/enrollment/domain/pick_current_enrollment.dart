import 'entities/enrollment.dart';

/// Chooses which of the student's enrollments the app should show.
///
/// A student can have several enrollment rows over time (one per semester).
/// The current session is the one whose dates contain today; when sessions
/// overlap or the student is between sessions, the active semester wins, then
/// the most recently started one.
Enrollment? pickCurrentEnrollment(List<Enrollment> enrollments, DateTime now) {
  if (enrollments.isEmpty) return null;

  final current = enrollments.where((e) => e.contains(now)).toList()
    ..sort(_byActiveThenStartDesc);
  if (current.isNotEmpty) return current.first;

  final active = enrollments.where((e) => e.isActive).toList()
    ..sort(_byActiveThenStartDesc);
  if (active.isNotEmpty) return active.first;

  return (enrollments.toList()..sort(_byActiveThenStartDesc)).first;
}

int _byActiveThenStartDesc(Enrollment a, Enrollment b) {
  if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
  final byStart = b.startDate.compareTo(a.startDate);
  if (byStart != 0) return byStart;
  return b.semesterId.compareTo(a.semesterId);
}
