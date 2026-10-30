import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation_keys.dart';
import 'notification_navigation.dart';
import 'startup_intent.dart';
import 'theme/app_theme.dart';
import 'router.dart';

class IntraBuddyApp extends ConsumerWidget {
  const IntraBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    if (StartupIntent.openLogbook) {
      StartupIntent.openLogbook = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openLogbookFromNotification(appRootNavigatorKey);
      });
    }

    return MaterialApp.router(
      title: 'INTRA Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
