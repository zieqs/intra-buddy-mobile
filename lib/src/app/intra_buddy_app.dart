import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'navigation_keys.dart';
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
        final navContext = appRootNavigatorKey.currentContext;
        if (navContext == null) return;
        GoRouter.of(navContext).push('/logbook');
      });
    }

    return MaterialApp.router(
      title: 'INTRA Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
