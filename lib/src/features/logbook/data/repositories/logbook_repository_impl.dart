import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/logbook_week.dart';
import '../../domain/repositories/logbook_repository.dart';
import '../datasources/logbook_remote_datasource.dart';

class LogbookRepositoryImpl implements LogbookRepository {
  final LogbookRemoteDataSource dataSource;

  LogbookRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<LogbookWeek>>> loadWeeks() async {
    try {
      final data = await dataSource.loadWeeks();
      final weeks = data.map((row) {
        return LogbookWeek(
          id: row['id'] as int,
          weekNumber: row['week_number'] as int,
          weekEndDate: DateTime.parse(row['week_end_date'] as String),
          isSubmitted: row['is_submitted'] as bool? ?? false,
          submittedAt: row['submitted_at'] != null
              ? DateTime.parse(row['submitted_at'] as String)
              : null,
        );
      }).toList();
      return Right(weeks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<LogbookWeek>> toggleSubmitted(int id, bool submitted) async {
    try {
      await dataSource.toggleSubmitted(id, submitted);
      return Right(
        LogbookWeek(
          id: id,
          weekNumber: 0,
          weekEndDate: DateTime.now(),
          isSubmitted: submitted,
          submittedAt: submitted ? DateTime.now() : null,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
