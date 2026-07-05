import '../../../../core/errors/failures.dart';
import '../entities/job_application.dart';
import '../repositories/job_repository.dart';

class UpdateApplication {
  final JobRepository repository;
  UpdateApplication(this.repository);

  Future<Result<JobApplication>> call({
    required int id,
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) {
    return repository.updateApplication(
      id: id,
      companyName: companyName,
      position: position,
      status: status,
      notes: notes,
    );
  }
}
