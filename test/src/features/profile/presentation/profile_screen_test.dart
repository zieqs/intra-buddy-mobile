import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/domain/entities/student_profile.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/presentation/providers/profile_controller.dart';
import 'package:intra_buddy_mobile_v2/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/auth_state_provider.dart';

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Result<StudentProfile>> loadProfile() async => const Right(
    StudentProfile(
      id: 'u1',
      email: 'student@s.unikl.edu.my',
      fullName: 'Aisyah Abdullah',
      studentId: 'B032310001',
    ),
  );

  @override
  Future<Result<StudentProfile>> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async => Right(
    StudentProfile(
      id: 'u1',
      email: 'student@s.unikl.edu.my',
      fullName: fullName,
      phoneNumber: phoneNumber,
    ),
  );
}

GoRouter _router() => GoRouter(
  initialLocation: '/profile',
  routes: [
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/my-documents',
      builder: (context, state) =>
          const Scaffold(body: Text('Document library')),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const Scaffold(body: Text('Settings page')),
    ),
  ],
);

Future<void> _pumpProfile(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authUserIdProvider.overrideWithValue('student-1'),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('opens the document library from the profile', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await _pumpProfile(tester, router);

    await tester.tap(find.text('My documents'));
    await tester.pumpAndSettle();

    expect(find.text('Document library'), findsOneWidget);
  });

  testWidgets('opens settings from the profile', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await _pumpProfile(tester, router);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings page'), findsOneWidget);
  });
}
