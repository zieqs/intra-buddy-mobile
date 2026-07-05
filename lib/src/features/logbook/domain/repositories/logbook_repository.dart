import '../../../../core/errors/failures.dart';
import '../entities/logbook_week.dart';

abstract class LogbookRepository {
  Future<Result<List<LogbookWeek>>> loadWeeks();
  Future<Result<LogbookWeek>> toggleSubmitted(int id, bool submitted);
}
