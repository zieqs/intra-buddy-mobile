import 'package:dartz/dartz.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, String> errors;
  const ValidationFailure(this.errors) : super('Validation failed');
}

/// Thrown when an operation needs a signed-in account but the session is gone.
///
/// Repositories surface it through their usual `Failure` path, so screens show
/// the message instead of a generic server error.
class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => 'Your session expired. Please sign in again.';
}

typedef Result<T> = Either<Failure, T>;
