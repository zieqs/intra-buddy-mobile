import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements NotificationRemoteDataSource {}

Map<String, dynamic> _row({required int id, required bool isRead}) => {
  'id': id,
  'title': 'Title $id',
  'body': 'Body $id',
  'type': 'system',
  'is_read': isRead,
  'created_at': '2026-10-27T08:00:00Z',
};

void main() {
  late _MockDataSource dataSource;
  late NotificationRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = NotificationRepositoryImpl(dataSource);
  });

  group('loadNotifications', () {
    test('does not change read state as a side effect of loading', () async {
      when(() => dataSource.loadNotifications()).thenAnswer(
        (_) async => [_row(id: 1, isRead: false), _row(id: 2, isRead: true)],
      );

      final result = await repository.loadNotifications();

      expect(result.isRight(), isTrue);
      verifyNever(() => dataSource.markAllAsRead());
      verifyNever(() => dataSource.markAsRead(any()));
    });

    test('preserves the unread flag returned by the server', () async {
      when(() => dataSource.loadNotifications()).thenAnswer(
        (_) async => [_row(id: 1, isRead: false), _row(id: 2, isRead: true)],
      );

      final items = (await repository.loadNotifications()).getOrElse(() => []);

      expect(items.firstWhere((n) => n.id == 1).isRead, isFalse);
      expect(items.firstWhere((n) => n.id == 2).isRead, isTrue);
    });

    test('parses broadcast image paths', () async {
      when(() => dataSource.loadNotifications()).thenAnswer(
        (_) async => [
          {
            ..._row(id: 1, isRead: false),
            'image_paths': ['broadcast-images/a.png', 'broadcast-images/b.png'],
          },
        ],
      );

      final items = (await repository.loadNotifications()).getOrElse(() => []);

      expect(items.single.imagePaths, [
        'broadcast-images/a.png',
        'broadcast-images/b.png',
      ]);
    });

    test('defaults image paths to empty when the column is missing', () async {
      when(
        () => dataSource.loadNotifications(),
      ).thenAnswer((_) async => [_row(id: 1, isRead: false)]);

      final items = (await repository.loadNotifications()).getOrElse(() => []);

      expect(items.single.imagePaths, isEmpty);
    });
  });

  group('markAllAsRead', () {
    test('delegates to the data source', () async {
      when(() => dataSource.markAllAsRead()).thenAnswer((_) async {});

      final result = await repository.markAllAsRead();

      expect(result.isRight(), isTrue);
      verify(() => dataSource.markAllAsRead()).called(1);
    });

    test('returns a failure when the data source throws', () async {
      when(() => dataSource.markAllAsRead()).thenThrow(Exception('offline'));

      final result = await repository.markAllAsRead();

      expect(result.isLeft(), isTrue);
    });
  });
}
