import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';
import '../models/job_application_model.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource dataSource;

  JobRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<JobApplication>>> loadApplications() async {
    try {
      final data = await dataSource.loadApplications();
      final items = data
          .map((json) => JobApplicationModel.fromJson(json))
          .toList();
      return Right(items.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<JobApplication>> addApplication({
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    try {
      final data = await dataSource.addApplication(
        companyName: companyName,
        position: position,
        status: status,
        notes: notes,
      );
      return Right(JobApplicationModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<JobApplication>> updateApplication({
    required int id,
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    try {
      final data = await dataSource.updateApplication(
        id: id,
        companyName: companyName,
        position: position,
        status: status,
        notes: notes,
      );
      return Right(JobApplicationModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteApplication(int id) async {
    try {
      await dataSource.deleteApplication(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
