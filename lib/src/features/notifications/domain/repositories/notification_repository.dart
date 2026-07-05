import '../../../../core/errors/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Result<List<AppNotification>>> loadNotifications();
  Future<Result<void>> markAsRead(int id);
  Future<Result<void>> deleteNotification(int id);
}
