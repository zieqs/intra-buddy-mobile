import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return NotificationRepositoryImpl(
    NotificationRemoteDataSource(authService, supabase),
  );
});

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, List<AppNotification>>(
      NotificationController.new,
    );

class NotificationController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final repo = ref.watch(notificationRepositoryProvider);
    final result = await repo.loadNotifications();
    return result.fold((failure) => throw failure, (items) => items);
  }

  Future<void> markAsRead(int id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsRead(id);
    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      _,
    ) {
      final current = state.value ?? [];
      state = AsyncData(
        current.map((n) {
          if (n.id == id) {
            return AppNotification(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
      ref.read(dashboardRefreshProvider.notifier).trigger();
    });
  }

  Future<void> deleteNotification(int id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.deleteNotification(id);
    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      _,
    ) {
      final current = state.value ?? [];
      state = AsyncData(current.where((n) => n.id != id).toList());
      ref.read(dashboardRefreshProvider.notifier).trigger();
    });
  }
}
