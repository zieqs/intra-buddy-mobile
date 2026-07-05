import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'router.dart';

class IntraBuddyApp extends StatelessWidget {
  const IntraBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'INTRA Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
