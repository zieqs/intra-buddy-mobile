import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repository;
  DeleteNotification(this.repository);

  Future<Result<void>> call(int id) => repository.deleteNotification(id);
}
