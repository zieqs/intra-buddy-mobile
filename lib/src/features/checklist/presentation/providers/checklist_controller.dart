import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../../data/datasources/checklist_remote_datasource.dart';
import '../../data/repositories/checklist_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return ChecklistRepositoryImpl(
    ChecklistRemoteDataSource(authService, supabase),
  );
});

final checklistControllerProvider =
    AsyncNotifierProvider<ChecklistController, List<ChecklistItem>>(
      ChecklistController.new,
    );

class ChecklistController extends AsyncNotifier<List<ChecklistItem>> {
  @override
  Future<List<ChecklistItem>> build() async {
    final repo = ref.watch(checklistRepositoryProvider);
    final result = await repo.loadChecklist();
    return result.fold((failure) => throw failure, (items) => items);
  }

  Future<void> toggleItem(int checklistId, bool completed) async {
    final repo = ref.read(checklistRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final current = [...state.value ?? <ChecklistItem>[]];
      final index = current.indexWhere((i) => i.id == checklistId);
      if (index != -1) {
        current[index] = ChecklistItem(
          id: current[index].id,
          checklistItemId: current[index].checklistItemId,
          title: current[index].title,
          description: current[index].description,
          isCompleted: completed,
          isRequired: current[index].isRequired,
          completedAt: completed ? DateTime.now() : current[index].completedAt,
          displayOrder: current[index].displayOrder,
        );
      }
      await repo.toggleItem(checklistId, completed);
      ref.read(dashboardRefreshProvider.notifier).trigger();
      return current;
    });
  }
}
