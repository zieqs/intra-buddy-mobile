import '../../../../core/errors/failures.dart';
import '../entities/job_application.dart';
import '../repositories/job_repository.dart';

class AddApplication {
  final JobRepository repository;
  AddApplication(this.repository);

  Future<Result<JobApplication>> call({
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) {
    return repository.addApplication(
      companyName: companyName,
      position: position,
      status: status,
      notes: notes,
    );
  }
}
