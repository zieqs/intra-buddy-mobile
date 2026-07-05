import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class AuthRemoteDataSource {
  final AuthService authService;

  AuthRemoteDataSource(this.authService);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return authService.signInWithEmail(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phone,
  }) {
    return authService.signUpStudent(
      email: email,
      password: password,
      fullName: fullName,
      studentId: studentId,
      phone: phone,
    );
  }

  Future<void> signOut() {
    return authService.signOut();
  }

  User? get currentUser => authService.currentUser;

  Stream<AuthState> get authStateChanges => authService.authStateChanges;
}
