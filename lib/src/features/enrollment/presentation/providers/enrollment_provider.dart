import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../data/enrollment_remote_datasource.dart';
import '../../domain/entities/enrollment.dart';

final enrollmentDataSourceProvider = Provider<EnrollmentRemoteDataSource>((
  ref,
) {
  return EnrollmentRemoteDataSource(ref.watch(supabaseClientProvider));
});

/// The student's current semester. Null means the account has no enrollment,
/// not that the lookup failed — errors stay as [AsyncError] so the UI can tell
/// the two apart.
final currentEnrollmentProvider = FutureProvider<Enrollment?>((ref) async {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) return null;
  return ref.watch(enrollmentDataSourceProvider).fetchCurrentEnrollment(userId);
});

/// The semester the coordinator has opened for registration. Used on the
/// signup screen, before the student has an account.
final openSemesterProvider = FutureProvider<Enrollment?>((ref) {
  return ref.watch(enrollmentDataSourceProvider).fetchOpenSemester();
});
