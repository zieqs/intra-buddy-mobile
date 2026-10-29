import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/domain/entities/app_notification.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/widgets/latest_notification_banner.dart';

AppNotification _notification({bool isRead = false, String? body}) {
  return AppNotification(
    id: 1,
    title: 'INTRA Briefing — 5 Nov 2026',
    body: body ?? 'Attendance is compulsory. Venue: MIIT Auditorium.',
    type: 'broadcast',
    isRead: isRead,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );
}

Widget _harness(
  AppNotification? notification, {
  int unreadCount = 1,
  String? imageUrl,
  VoidCallback? onTap,
  bool isLoading = false,
  bool hasError = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: LatestNotificationBanner(
        notification: notification,
        unreadCount: unreadCount,
        imageUrl: imageUrl,
        isLoading: isLoading,
        hasError: hasError,
        onTap: onTap ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the latest notification with time and unread count', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_notification(), unreadCount: 4));

    expect(find.text('Latest notification'), findsOneWidget);
    expect(find.text('INTRA Briefing — 5 Nov 2026'), findsOneWidget);
    expect(find.textContaining('Attendance is compulsory'), findsOneWidget);
    expect(find.text('4 unread'), findsOneWidget);
    expect(find.text('5m ago'), findsOneWidget);
  });

  testWidgets('hides the unread count for a read notification', (tester) async {
    await tester.pumpWidget(
      _harness(_notification(isRead: true), unreadCount: 0),
    );

    expect(find.textContaining('unread'), findsNothing);
  });

  testWidgets('shows an image when one is available', (tester) async {
    await tester.pumpWidget(
      _harness(_notification(), imageUrl: 'https://example.com/broadcast.png'),
    );

    expect(
      find.byKey(const ValueKey('latest-notification-image')),
      findsOneWidget,
    );
  });

  testWidgets('reports a tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _harness(_notification(), onTap: () => tapped = true),
    );

    await tester.tap(find.byType(LatestNotificationBanner));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shows an empty state when the inbox is empty', (tester) async {
    await tester.pumpWidget(_harness(null));

    expect(find.text('No notifications'), findsOneWidget);
    expect(find.text("You're all caught up"), findsOneWidget);
  });

  testWidgets('shows a loading state', (tester) async {
    await tester.pumpWidget(_harness(null, isLoading: true));

    expect(find.text('Loading notifications…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an error state', (tester) async {
    await tester.pumpWidget(_harness(null, hasError: true));

    expect(find.text("Couldn't load notifications"), findsOneWidget);
    expect(find.text('Open the inbox to try again'), findsOneWidget);
  });

  testWidgets('the empty state is still tappable', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_harness(null, onTap: () => tapped = true));

    await tester.tap(find.byType(LatestNotificationBanner));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
