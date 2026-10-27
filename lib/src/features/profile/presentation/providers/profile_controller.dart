import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return ProfileRepositoryImpl(ProfileRemoteDataSource(authService, supabase));
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, StudentProfile>(
      ProfileController.new,
    );

class ProfileController extends AsyncNotifier<StudentProfile> {
  @override
  Future<StudentProfile> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final result = await repo.loadProfile();
    return result.fold((failure) => throw failure, (profile) => profile);
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    return result.fold((_) => false, (profile) {
      state = AsyncData(profile);
      return true;
    });
  }
}
