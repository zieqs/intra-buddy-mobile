class JobApplication {
  final int id;
  final String companyName;
  final String? position;
  final DateTime applicationDate;
  final String status;
  final String? notes;

  const JobApplication({
    required this.id,
    required this.companyName,
    this.position,
    required this.applicationDate,
    required this.status,
    this.notes,
  });
}
