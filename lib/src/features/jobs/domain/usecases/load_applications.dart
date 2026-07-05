import '../../../../core/errors/failures.dart';
import '../entities/job_application.dart';
import '../repositories/job_repository.dart';

class LoadApplications {
  final JobRepository repository;
  LoadApplications(this.repository);

  Future<Result<List<JobApplication>>> call() {
    return repository.loadApplications();
  }
}
