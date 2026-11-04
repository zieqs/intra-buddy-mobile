import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<supabase.AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges;
});

final currentUserProvider = Provider<supabase.User?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.hasValue) return authState.value?.session?.user;
  return ref.watch(authServiceProvider).currentUser;
});

/// The current account id. User-scoped providers watch this so a sign-out or
/// account switch invalidates their cached data.
final authUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});
