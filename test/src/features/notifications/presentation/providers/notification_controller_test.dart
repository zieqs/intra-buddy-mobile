import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/auth_state_provider.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/data/datasources/notification_realtime_datasource.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/domain/entities/app_notification.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/domain/repositories/notification_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/providers/notification_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository(this.items);

  List<AppNotification> items;
  bool failWrites = false;
  int markAllCalls = 0;
  int loadCalls = 0;
  final List<int> markedIds = [];

  @override
  Future<Result<List<AppNotification>>> loadNotifications() async {
    loadCalls++;
    return Right(items);
  }

  @override
  Future<Result<void>> markAsRead(int id) async {
    markedIds.add(id);
    if (failWrites) return const Left(ServerFailure('write failed'));
    items = items
        .map((n) => n.id == id ? _asRead(n) : n)
        .toList(growable: false);
    return const Right(null);
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    markAllCalls++;
    if (failWrites) return const Left(ServerFailure('write failed'));
    items = items.map(_asRead).toList(growable: false);
    return const Right(null);
  }

  @override
  Future<Result<void>> deleteNotification(int id) async {
    items = items.where((n) => n.id != id).toList(growable: false);
    return const Right(null);
  }
}

AppNotification _asRead(AppNotification n) => AppNotification(
  id: n.id,
  title: n.title,
  body: n.body,
  type: n.type,
  isRead: true,
  createdAt: n.createdAt,
);

class _FakeRealtimeSource implements NotificationRealtimeSource {
  void Function()? onChange;

  @override
  void watch({required void Function() onChange}) {
    this.onChange = onChange;
  }
}

List<AppNotification> _seed() => [
  AppNotification(
    id: 1,
    title: 'Briefing',
    isRead: false,
    createdAt: DateTime(2026, 10, 27),
  ),
  AppNotification(
    id: 2,
    title: 'Deadline',
    isRead: false,
    createdAt: DateTime(2026, 10, 26),
  ),
  AppNotification(
    id: 3,
    title: 'Old news',
    isRead: true,
    createdAt: DateTime(2026, 10, 20),
  ),
];

void main() {
  late _FakeNotificationRepository repo;
  late _FakeRealtimeSource realtime;
  late ProviderContainer container;

  Future<void> setUpContainer() async {
    container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(repo),
        notificationRealtimeProvider.overrideWithValue(realtime),
      ],
    );
    addTearDown(container.dispose);
    await container.read(notificationControllerProvider.future);
  }

  setUp(() {
    repo = _FakeNotificationRepository(_seed());
    realtime = _FakeRealtimeSource();
  });

  group('unread count', () {
    test('counts only unread notifications', () async {
      await setUpContainer();

      expect(container.read(unreadNotificationCountProvider), 2);
    });

    test('drops to zero when every notification is read', () async {
      await setUpContainer();
      repo.items = repo.items.map(_asRead).toList();
      container.invalidate(notificationControllerProvider);

      await container.read(notificationControllerProvider.future);

      expect(container.read(unreadNotificationCountProvider), 0);
    });
  });

  group('markAsRead', () {
    test('marks only the tapped notification as read', () async {
      await setUpContainer();

      await container
          .read(notificationControllerProvider.notifier)
          .markAsRead(1);

      final items = container.read(notificationControllerProvider).requireValue;
      expect(items.firstWhere((n) => n.id == 1).isRead, isTrue);
      expect(items.firstWhere((n) => n.id == 2).isRead, isFalse);
      expect(container.read(unreadNotificationCountProvider), 1);
    });

    test('does not write again for an already-read notification', () async {
      await setUpContainer();

      await container
          .read(notificationControllerProvider.notifier)
          .markAsRead(3);

      expect(repo.markedIds, isEmpty);
    });

    test('rolls back the optimistic update when the write fails', () async {
      await setUpContainer();
      repo.failWrites = true;

      await container
          .read(notificationControllerProvider.notifier)
          .markAsRead(1);

      final items = container.read(notificationControllerProvider).requireValue;
      expect(items.firstWhere((n) => n.id == 1).isRead, isFalse);
      expect(container.read(unreadNotificationCountProvider), 2);
    });
  });

  group('markAllAsRead', () {
    test('marks every notification as read', () async {
      await setUpContainer();

      await container
          .read(notificationControllerProvider.notifier)
          .markAllAsRead();

      expect(repo.markAllCalls, 1);
      expect(container.read(unreadNotificationCountProvider), 0);
    });

    test('rolls back when the write fails', () async {
      await setUpContainer();
      repo.failWrites = true;

      await container
          .read(notificationControllerProvider.notifier)
          .markAllAsRead();

      expect(container.read(unreadNotificationCountProvider), 2);
    });
  });

  group('realtime', () {
    test('refreshes the inbox when a database change arrives', () async {
      await setUpContainer();
      expect(repo.loadCalls, 1);

      repo.items = [
        AppNotification(
          id: 99,
          title: 'Just arrived',
          isRead: false,
          createdAt: DateTime(2026, 10, 27),
        ),
        ...repo.items,
      ];
      realtime.onChange!();
      await container.pump();

      expect(repo.loadCalls, 2);
      expect(container.read(unreadNotificationCountProvider), 3);
    });
  });

  group('session changes', () {
    test('reloads the inbox when the auth state changes', () async {
      final authEvents = StreamController<AuthState>.broadcast();
      addTearDown(authEvents.close);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repo),
          notificationRealtimeProvider.overrideWithValue(realtime),
          authStateProvider.overrideWith((ref) => authEvents.stream),
        ],
      );
      addTearDown(container.dispose);
      container.listen(
        notificationControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await container.read(notificationControllerProvider.future);
      expect(repo.loadCalls, 1);

      authEvents.add(const AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(repo.loadCalls, 2);
    });
  });
}
