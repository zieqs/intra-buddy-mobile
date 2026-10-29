import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class ArchiveNotification {
  final NotificationRepository repository;
  ArchiveNotification(this.repository);

  Future<Result<void>> call(int id) => repository.archiveNotification(id);
}
