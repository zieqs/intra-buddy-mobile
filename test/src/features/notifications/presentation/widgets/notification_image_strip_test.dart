import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/widgets/notification_image_strip.dart';

Widget _harness(List<String> urls, {ValueChanged<int>? onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: NotificationImageStrip(imageUrls: urls, onTap: onTap ?? (_) {}),
    ),
  );
}

void main() {
  testWidgets('renders nothing without images', (tester) async {
    await tester.pumpWidget(_harness(const []));

    expect(find.byType(NotificationImageStrip), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-image-0')), findsNothing);
  });

  testWidgets('shows at most three thumbnails with a +N counter', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness([
        'https://example.com/1.png',
        'https://example.com/2.png',
        'https://example.com/3.png',
        'https://example.com/4.png',
      ]),
    );

    expect(find.byKey(const ValueKey('notification-image-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-image-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-image-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-image-3')), findsNothing);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('reports the tapped image index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _harness([
        'https://example.com/1.png',
        'https://example.com/2.png',
      ], onTap: (index) => tapped = index),
    );

    await tester.tap(find.byKey(const ValueKey('notification-image-1')));
    await tester.pump();

    expect(tapped, 1);
  });
}
