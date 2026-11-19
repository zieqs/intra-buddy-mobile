import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../data/enrollment_remote_datasource.dart';
import '../../data/repositories/enrollment_repository_impl.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepositoryImpl(
    EnrollmentRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

/// The student's current semester. Null means the account has no enrollment,
/// not that the lookup failed — errors stay as [AsyncError] so the UI can tell
/// the two apart.
final currentEnrollmentProvider = FutureProvider<Enrollment?>((ref) async {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) return null;

  final result = await ref
      .watch(enrollmentRepositoryProvider)
      .currentFor(userId);
  return result.fold((failure) => throw failure, (enrollment) => enrollment);
});

/// The semester the coordinator has opened for registration. Used on the
/// signup screen, before the student has an account.
final openSemesterProvider = FutureProvider<Enrollment?>((ref) async {
  final result = await ref.watch(enrollmentRepositoryProvider).openSemester();
  return result.fold((failure) => throw failure, (enrollment) => enrollment);
});
