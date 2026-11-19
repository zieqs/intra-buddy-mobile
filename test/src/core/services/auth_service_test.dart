import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/core/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;
  late AuthService service;

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    service = AuthService(client: client);
  });

  group('requireUserId', () {
    test('returns the signed-in account id', () {
      final user = _MockUser();
      when(() => user.id).thenReturn('user-1');
      when(() => auth.currentUser).thenReturn(user);

      expect(service.requireUserId(), 'user-1');
      verifyNever(() => auth.signOut());
    });

    test('clears the stale session and reports expiry', () {
      when(() => auth.currentUser).thenReturn(null);
      when(() => auth.signOut()).thenAnswer((_) async {});

      expect(
        () => service.requireUserId(),
        throwsA(isA<SessionExpiredException>()),
      );
      verify(() => auth.signOut()).called(1);
    });

    test('keeps the original failure message for the UI', () {
      when(() => auth.currentUser).thenReturn(null);
      when(() => auth.signOut()).thenAnswer((_) async {});

      expect(
        () => service.requireUserId(),
        throwsA(
          predicate<SessionExpiredException>(
            (e) =>
                e.toString() == 'Your session expired. Please sign in again.',
          ),
        ),
      );
    });
  });
}
