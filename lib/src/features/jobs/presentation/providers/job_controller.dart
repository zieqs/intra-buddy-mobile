import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/datasources/job_remote_datasource.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return JobRepositoryImpl(JobRemoteDataSource(authService, supabase));
});

final jobControllerProvider =
    AsyncNotifierProvider<JobController, List<JobApplication>>(
      JobController.new,
    );

class JobController extends AsyncNotifier<List<JobApplication>> {
  @override
  Future<List<JobApplication>> build() async {
    final repo = ref.watch(jobRepositoryProvider);
    final result = await repo.loadApplications();
    return result.fold((failure) => throw failure, (items) => items);
  }

  Future<void> addApplication({
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    final repo = ref.read(jobRepositoryProvider);
    final result = await repo.addApplication(
      companyName: companyName,
      position: position,
      status: status,
      notes: notes,
    );
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> updateApplication({
    required int id,
    required String companyName,
    String? position,
    required String status,
    String? notes,
  }) async {
    final repo = ref.read(jobRepositoryProvider);
    final result = await repo.updateApplication(
      id: id,
      companyName: companyName,
      position: position,
      status: status,
      notes: notes,
    );
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> deleteApplication(int id) async {
    final repo = ref.read(jobRepositoryProvider);
    final result = await repo.deleteApplication(id);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

final _statusValues = ['Pending', 'Interview', 'Offer', 'Rejected', 'Accepted'];

String statusLabel(String status) => status;
List<String> get statusValues => _statusValues;
