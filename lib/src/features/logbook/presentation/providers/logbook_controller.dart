import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/logbook_week.dart';
import '../../domain/repositories/logbook_repository.dart';
import '../../data/datasources/logbook_remote_datasource.dart';
import '../../data/repositories/logbook_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';

final logbookRepositoryProvider = Provider<LogbookRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return LogbookRepositoryImpl(LogbookRemoteDataSource(authService, supabase));
});

final logbookControllerProvider =
    AsyncNotifierProvider<LogbookController, List<LogbookWeek>>(
      LogbookController.new,
    );

class LogbookController extends AsyncNotifier<List<LogbookWeek>> {
  @override
  Future<List<LogbookWeek>> build() async {
    final repo = ref.watch(logbookRepositoryProvider);
    final result = await repo.loadWeeks();
    return result.fold((failure) => throw failure, (weeks) => weeks);
  }

  Future<void> toggleSubmitted(int id, bool submitted) async {
    final repo = ref.read(logbookRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final current = [...state.value ?? []];
      final index = current.indexWhere((w) => w.id == id);
      if (index != -1) {
        current[index] = LogbookWeek(
          id: current[index].id,
          weekNumber: current[index].weekNumber,
          weekEndDate: current[index].weekEndDate,
          isSubmitted: submitted,
          submittedAt: submitted ? DateTime.now() : null,
        );
      }
      await repo.toggleSubmitted(id, submitted);
      return current;
    });
  }
}
