import '../../../../core/errors/failures.dart';
import '../repositories/job_repository.dart';

class DeleteApplication {
  final JobRepository repository;
  DeleteApplication(this.repository);

  Future<Result<void>> call(int id) {
    return repository.deleteApplication(id);
  }
}
