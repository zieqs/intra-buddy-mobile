import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intra_buddy_mobile_v2/src/app/notification_navigation.dart';

void main() {
  testWidgets('a notification tap switches to the logbook without duplicates', (
    tester,
  ) async {
    final rootKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      navigatorKey: rootKey,
      initialLocation: '/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const Text('Home page'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/logbook',
                  builder: (context, state) => const Text('Logbook page'),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Text('Settings page'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Home page'), findsOneWidget);

    // The notification arrives while a page sits above the shell, as when the
    // test notification is tapped from Settings.
    router.push('/settings');
    await tester.pumpAndSettle();
    expect(find.text('Settings page'), findsOneWidget);

    openLogbookFromNotification(rootKey);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Logbook page'), findsOneWidget);
  });

  testWidgets('a tap before the router is ready does nothing', (tester) async {
    final rootKey = GlobalKey<NavigatorState>();

    expect(() => openLogbookFromNotification(rootKey), returnsNormally);
  });
}
