import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/auth_state_provider.dart';
import 'navigation_keys.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/email_confirmation_screen.dart';
import '../features/dashboard/presentation/screens/student_shell.dart';
import '../features/dashboard/presentation/screens/dashboard_home.dart';
import '../features/checklist/presentation/screens/checklist_screen.dart';
import '../features/jobs/presentation/screens/jobs_screen.dart';
import '../features/chatbot/presentation/screens/chatbot_screen.dart';
import '../features/my_documents/presentation/screens/my_documents_screen.dart';
import '../features/notifications/presentation/screens/notification_screen.dart';
import '../features/logbook/presentation/screens/logbook_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final authRefresh = ValueNotifier<int>(0);
  final subscription = authService.authStateChanges.listen(
    (_) => authRefresh.value++,
  );

  final router = GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final isLoggedIn = authService.currentUser != null;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation.startsWith('/email-confirmation');

      if (!isLoggedIn && !isOnAuthPage) return '/login';
      if (isLoggedIn && isOnAuthPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/email-confirmation',
        name: 'email-confirmation',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailConfirmationScreen(email: email);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StudentShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardHome(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/checklist',
                name: 'checklist',
                builder: (context, state) => const ChecklistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                name: 'jobs',
                builder: (context, state) => const JobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                builder: (context, state) => const ChatbotScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: appRootNavigatorKey,
        path: '/my-documents',
        name: 'my-documents',
        builder: (context, state) => const MyDocumentsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: appRootNavigatorKey,
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: appRootNavigatorKey,
        path: '/logbook',
        name: 'logbook',
        builder: (context, state) => const LogbookScreen(),
      ),
      GoRoute(
        parentNavigatorKey: appRootNavigatorKey,
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: appRootNavigatorKey,
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    subscription.cancel();
    router.dispose();
    authRefresh.dispose();
  });

  return router;
});
