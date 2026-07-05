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
  final auth = ref.watch(authServiceProvider);
  return auth.currentUser;
});
