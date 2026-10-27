import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/providers/notification_controller.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/widgets/notification_bell.dart';

Widget _harness(int unread) {
  return ProviderScope(
    overrides: [unreadNotificationCountProvider.overrideWithValue(unread)],
    child: MaterialApp(
      home: Scaffold(appBar: AppBar(actions: const [NotificationBell()])),
    ),
  );
}

void main() {
  testWidgets('shows the unread count on the bell', (tester) async {
    await tester.pumpWidget(_harness(5));

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('hides the badge when there is nothing unread', (tester) async {
    await tester.pumpWidget(_harness(0));

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('caps large counts at 99+', (tester) async {
    await tester.pumpWidget(_harness(150));

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('anchors the badge to the bell, not the app bar edge', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(5));

    expect(
      find.descendant(of: find.byType(IconButton), matching: find.text('5')),
      findsOneWidget,
    );
  });
}
