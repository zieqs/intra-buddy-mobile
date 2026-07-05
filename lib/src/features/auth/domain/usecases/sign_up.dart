import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<Result<User>> call({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phone,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      studentId: studentId,
      phone: phone,
    );
  }
}
