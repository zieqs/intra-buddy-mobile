import '../../../../core/errors/failures.dart';
import '../entities/job_application.dart';

abstract class JobRepository {
  Future<Result<List<JobApplication>>> loadApplications();
  Future<Result<JobApplication>> addApplication({
    required String companyName,
    String? position,
    required String status,
    String? notes,
  });
  Future<Result<JobApplication>> updateApplication({
    required int id,
    required String companyName,
    String? position,
    required String status,
    String? notes,
  });
  Future<Result<void>> deleteApplication(int id);
}
