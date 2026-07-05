import '../entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phone,
  });

  Future<Result<void>> signOut();

  Result<User> getCurrentUser();

  Stream<User?> authStateChanges();
}
