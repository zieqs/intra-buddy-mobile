import '../../../../core/errors/failures.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class LoadNotifications {
  final NotificationRepository repository;
  LoadNotifications(this.repository);

  Future<Result<List<AppNotification>>> call() =>
      repository.loadNotifications();
}
