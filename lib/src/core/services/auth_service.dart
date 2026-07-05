import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../constants/app_constants.dart';

class AuthService {
  supabase.SupabaseClient get _client => supabase.Supabase.instance.client;

  supabase.User? get currentUser => _client.auth.currentUser;

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
