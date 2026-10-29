import '../../../../core/errors/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Result<List<AppNotification>>> loadNotifications();
  Future<Result<void>> markAsRead(int id);
  Future<Result<void>> markAllAsRead();
  Future<Result<int>> archiveReadNotifications();
  Future<Result<void>> archiveNotification(int id);
}
