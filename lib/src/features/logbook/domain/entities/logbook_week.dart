class LogbookWeek {
  final int id;
  final int weekNumber;
  final DateTime weekEndDate;
  final bool isSubmitted;
  final DateTime? submittedAt;

  const LogbookWeek({
    required this.id,
    required this.weekNumber,
    required this.weekEndDate,
    required this.isSubmitted,
    this.submittedAt,
  });
}
