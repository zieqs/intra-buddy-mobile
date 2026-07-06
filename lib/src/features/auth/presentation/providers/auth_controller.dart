import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/entities/user.dart';
import '../../../../core/errors/failures.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(AuthRemoteDataSource(authService));
});

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    if (user == null) return null;
    final repo = ref.watch(authRepositoryProvider);
    final result = repo.getCurrentUser();
    return result.fold((_) => null, (user) => user);
  }

  static String mapAuthError(String raw) {
    if (raw.contains('already registered')) {
      return 'An account with this email already exists. Try signing in.';
    }
    if (raw.contains('validate email')) {
      return 'Please enter a valid @s.unikl.edu.my email';
    }
    if (raw.contains('connect') || raw.contains('network') || raw.contains('internet')) {
      return 'Unable to connect. Please check your internet and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signIn(email: email, password: password);
    result.fold(
      (failure) {
        final message = failure is AuthFailure
            ? AuthController.mapAuthError(failure.message)
            : failure.message;
        state = AsyncError(AuthFailure(message), StackTrace.current);
      },
      (user) => state = AsyncData(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phone,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      studentId: studentId,
      phone: phone,
    );
    result.fold(
      (failure) {
        final message = failure is AuthFailure
            ? AuthController.mapAuthError(failure.message)
            : failure.message;
        state = AsyncError(AuthFailure(message), StackTrace.current);
      },
      (user) => state = AsyncData(user),
    );
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signOut();
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}
