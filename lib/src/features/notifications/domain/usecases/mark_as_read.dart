import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class MarkAsRead {
  final NotificationRepository repository;
  MarkAsRead(this.repository);

  Future<Result<void>> call(int id) => repository.markAsRead(id);
}
