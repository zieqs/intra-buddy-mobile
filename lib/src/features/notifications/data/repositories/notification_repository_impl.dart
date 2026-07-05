import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<AppNotification>>> loadNotifications() async {
    try {
      final data = await dataSource.loadNotifications();
      dataSource.markAllAsRead();
      final items = data
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      return Right(items.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead(int id) async {
    try {
      await dataSource.markAsRead(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteNotification(int id) async {
    try {
      await dataSource.deleteNotification(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
