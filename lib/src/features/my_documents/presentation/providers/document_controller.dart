import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repositories/document_repository.dart';
import '../../data/datasources/document_remote_datasource.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return DocumentRepositoryImpl(
    DocumentRemoteDataSource(authService, supabase),
  );
});

final documentControllerProvider =
    AsyncNotifierProvider<DocumentController, List<DocumentItem>>(
      DocumentController.new,
    );

class DocumentController extends AsyncNotifier<List<DocumentItem>> {
  @override
  Future<List<DocumentItem>> build() async {
    final repo = ref.watch(documentRepositoryProvider);
    final result = await repo.loadDocuments();
    return result.fold((failure) => throw failure, (items) => items);
  }

  Future<void> uploadDocument({
    required String filePath,
    required String itemName,
    String? notes,
  }) async {
    final repo = ref.read(documentRepositoryProvider);
    final result = await repo.uploadDocument(
      filePath: filePath,
      itemName: itemName,
      notes: notes,
    );
    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      _,
    ) {
      ref.invalidateSelf();
      ref.read(dashboardRefreshProvider.notifier).trigger();
    });
  }

  Future<String> getViewUrl(String storagePath) async {
    final repo = ref.read(documentRepositoryProvider);
    final result = await repo.getViewUrl(storagePath);
    return result.fold((failure) => throw failure, (url) => url);
  }

  Future<void> deleteDocument(int id, String storagePath) async {
    final repo = ref.read(documentRepositoryProvider);
    final result = await repo.deleteDocument(id, storagePath);
    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      _,
    ) {
      ref.invalidateSelf();
      ref.read(dashboardRefreshProvider.notifier).trigger();
    });
  }
}
