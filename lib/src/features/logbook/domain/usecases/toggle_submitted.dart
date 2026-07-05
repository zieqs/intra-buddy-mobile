import '../../../../core/errors/failures.dart';
import '../entities/logbook_week.dart';
import '../repositories/logbook_repository.dart';

class ToggleSubmitted {
  final LogbookRepository repository;
  ToggleSubmitted(this.repository);

  Future<Result<LogbookWeek>> call(int id, bool submitted) {
    return repository.toggleSubmitted(id, submitted);
  }
}
