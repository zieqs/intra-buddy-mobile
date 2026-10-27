import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/datasources/notification_realtime_datasource.dart';
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

final notificationRealtimeProvider = Provider<NotificationRealtimeSource>((
  ref,
) {
  final source = SupabaseNotificationRealtimeSource(
    ref.watch(authServiceProvider),
    ref.watch(supabaseClientProvider),
  );
  ref.onDispose(source.dispose);
  return source;
});

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, List<AppNotification>>(
      NotificationController.new,
    );

/// Unread badge count, derived from the loaded inbox so the shell and the
/// notifications screen can never disagree.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationControllerProvider).value;
  if (items == null) return 0;
  return items.where((notification) => !notification.isRead).length;
});

class NotificationController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    // Reload whenever the session changes so one user's inbox (and badge)
    // can never leak into another user's session.
    ref.watch(authStateProvider);

    // Live updates: new broadcasts, reads from another device, deletions.
    ref.watch(notificationRealtimeProvider).watch(onChange: _refreshFromServer);

    final repo = ref.watch(notificationRepositoryProvider);
    final result = await repo.loadNotifications();
    return result.fold((failure) => throw failure, (items) => items);
  }

  /// Pulls the latest inbox without flashing a loading state, so the badge and
  /// list update in place when Realtime fires.
  Future<void> _refreshFromServer() async {
    final result = await ref
        .read(notificationRepositoryProvider)
        .loadNotifications();
    if (!ref.mounted) return;
    result.fold((_) {}, (items) => state = AsyncData(items));
  }

  Future<void> markAsRead(int id) async {
    final current = state.value;
    if (current == null) return;

    final matches = current.where((n) => n.id == id);
    if (matches.isEmpty || matches.first.isRead) return;

    state = AsyncData(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );

    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsRead(id);
    result.fold(
      (_) => state = AsyncData(current),
      (_) => ref.read(dashboardRefreshProvider.notifier).trigger(),
    );
  }

  Future<void> markAllAsRead() async {
    final current = state.value;
    if (current == null || current.every((n) => n.isRead)) return;

    state = AsyncData(current.map((n) => n.copyWith(isRead: true)).toList());

    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAllAsRead();
    result.fold(
      (_) => state = AsyncData(current),
      (_) => ref.read(dashboardRefreshProvider.notifier).trigger(),
    );
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
