import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../enrollment_remote_datasource.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  EnrollmentRepositoryImpl(this._dataSource);

  final EnrollmentRemoteDataSource _dataSource;

  @override
  Future<Result<Enrollment?>> currentFor(String userId, {DateTime? now}) async {
    try {
      return Right(await _dataSource.fetchCurrentEnrollment(userId, now: now));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<Enrollment?>> openSemester() async {
    try {
      return Right(await _dataSource.fetchOpenSemester());
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
