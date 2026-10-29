import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/logbook_week.dart';
import '../../domain/repositories/logbook_repository.dart';
import '../../data/datasources/logbook_remote_datasource.dart';
import '../../data/repositories/logbook_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';

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

  Future<bool> toggleSubmitted(int id, bool submitted) async {
    final current = state.value;
    if (current == null) return false;

    final index = current.indexWhere((week) => week.id == id);
    if (index == -1) return false;
    if (current[index].isSubmitted == submitted) return true;

    final target = current[index];
    final optimistic = [...current];
    optimistic[index] = LogbookWeek(
      id: target.id,
      weekNumber: target.weekNumber,
      weekEndDate: target.weekEndDate,
      isSubmitted: submitted,
      submittedAt: submitted ? DateTime.now() : null,
    );
    state = AsyncData(optimistic);

    final repo = ref.read(logbookRepositoryProvider);
    final result = await repo.toggleSubmitted(id, submitted);
    return result.fold(
      (_) {
        state = AsyncData(current);
        return false;
      },
      (_) {
        ref.read(dashboardRefreshProvider.notifier).trigger();
        return true;
      },
    );
  }
}
