import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class AuthService {
  AuthService({supabase.SupabaseClient? client}) : _clientOverride = client;

  final supabase.SupabaseClient? _clientOverride;

  supabase.SupabaseClient get _client =>
      _clientOverride ?? supabase.Supabase.instance.client;

  supabase.User? get currentUser => _client.auth.currentUser;

  /// The signed-in account id, or a [SessionExpiredException] when the session
  /// has gone away.
  ///
  /// Datasources use this instead of `currentUser!.id`: a missing session is a
  /// normal runtime state (expired refresh token, revoked account), not a bug.
  /// Clearing the stale local session lets the router redirect to sign-in.
  String requireUserId() {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      unawaited(_client.auth.signOut().catchError((_) {}));
      throw const SessionExpiredException();
    }
    return id;
  }

  Stream<supabase.AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  Future<supabase.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<supabase.AuthResponse> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phone,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'student_id': studentId,
        'phone_number': phone,
        'role': 'student',
      },
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  bool isValidStudentEmail(String email) {
    return email.trim().toLowerCase().endsWith(AppConstants.studentEmailDomain);
  }

  bool isValidStudentId(String id) {
    return id.length == AppConstants.studentIdLength &&
        RegExp(r'^\d+$').hasMatch(id);
  }

  bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return cleaned.length >= 9 &&
        cleaned.length <= 12 &&
        RegExp(r'^\d+$').hasMatch(cleaned);
  }
}
