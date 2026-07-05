import '../../../../core/errors/failures.dart';
import '../entities/logbook_week.dart';
import '../repositories/logbook_repository.dart';

class LoadWeeks {
  final LogbookRepository repository;
  LoadWeeks(this.repository);

  Future<Result<List<LogbookWeek>>> call() => repository.loadWeeks();
}
