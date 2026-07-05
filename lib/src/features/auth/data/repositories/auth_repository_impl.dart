import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dataSource.signIn(
        email: email,
        password: password,
      );
      final supabaseUser = response.user;
      if (supabaseUser == null) {
        return const Left(AuthFailure('Sign in failed'));
      }
      return Right(UserModel.fromSupabaseUser(supabaseUser).toEntity());
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phone,
  }) async {
    try {
      final response = await dataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
        phone: phone,
      );
      final supabaseUser = response.user;
      if (supabaseUser == null) {
        return const Left(AuthFailure('Sign up failed'));
      }
      return Right(UserModel.fromSupabaseUser(supabaseUser).toEntity());
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Result<User> getCurrentUser() {
    final supabaseUser = dataSource.currentUser;
    if (supabaseUser == null) {
      return const Left(AuthFailure('No user logged in'));
    }
    return Right(UserModel.fromSupabaseUser(supabaseUser).toEntity());
  }

  @override
  Stream<User?> authStateChanges() {
    return dataSource.authStateChanges.map((event) {
      final session = event.session;
      final supabaseUser = session?.user;
      if (supabaseUser == null) return null;
      return UserModel.fromSupabaseUser(supabaseUser).toEntity();
    });
  }
}
