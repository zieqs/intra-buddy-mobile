import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/router.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/auth_state_provider.dart';
import 'package:intra_buddy_mobile_v2/src/core/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthService extends Mock implements AuthService {}

void main() {
  test('reuses one router instance across auth state changes', () async {
    final events = StreamController<AuthState>.broadcast();
    addTearDown(events.close);

    final auth = _MockAuthService();
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.authStateChanges).thenAnswer((_) => events.stream);

    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(auth)],
    );
    addTearDown(container.dispose);
    container.listen(appRouterProvider, (_, _) {}, fireImmediately: true);

    final first = container.read(appRouterProvider);

    events.add(const AuthState(AuthChangeEvent.signedOut, null));
    await Future<void>.delayed(Duration.zero);
    await container.pump();

    final second = container.read(appRouterProvider);

    expect(identical(first, second), isTrue);
  });
}
