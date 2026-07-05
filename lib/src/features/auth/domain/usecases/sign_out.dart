import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<Result<void>> call() {
    return repository.signOut();
  }
}
