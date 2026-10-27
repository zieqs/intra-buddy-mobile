import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/domain/entities/document_item.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/domain/repositories/document_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/presentation/providers/document_controller.dart';

class _FakeDocumentRepository implements DocumentRepository {
  final List<DocumentItem> items = [];
  bool failUploads = false;
  String failureMessage = 'new row violates row-level security policy';
  int uploadCalls = 0;
  int loadCalls = 0;

  @override
  Future<Result<List<DocumentItem>>> loadDocuments() async {
    loadCalls++;
    return Right(items);
  }

  @override
  Future<Result<DocumentItem>> uploadDocument({
    required String filePath,
    required String itemName,
    String? notes,
  }) async {
    uploadCalls++;
    if (failUploads) return Left(ServerFailure(failureMessage));
    final item = DocumentItem(
      id: 1,
      itemName: itemName,
      filePath: filePath,
      fileType: 'pdf',
      uploadedAt: DateTime(2026, 10, 27),
    );
    items.add(item);
    return Right(item);
  }

  @override
  Future<Result<String>> getViewUrl(String storagePath) async =>
      const Right('https://example.com/signed');

  @override
  Future<Result<void>> deleteDocument(int id, String storagePath) async =>
      const Right(null);
}

void main() {
  late _FakeDocumentRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = _FakeDocumentRepository();
    container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(documentControllerProvider.future);
  });

  group('uploadDocument', () {
    test('returns null on success', () async {
      final message = await container
          .read(documentControllerProvider.notifier)
          .uploadDocument(filePath: '/cache/CV.pdf', itemName: 'CV');

      expect(message, isNull);
      expect(repo.uploadCalls, 1);
    });

    test('returns a message and keeps the list when storage rejects', () async {
      repo.failUploads = true;

      final message = await container
          .read(documentControllerProvider.notifier)
          .uploadDocument(filePath: '/cache/CV.pdf', itemName: 'CV');

      expect(message, 'Could not upload. Please try again.');
      expect(container.read(documentControllerProvider).hasError, isFalse);
      expect(container.read(documentControllerProvider).value, isNotNull);
    });

    test('surfaces the size limit as a specific message', () async {
      repo.failUploads = true;
      repo.failureMessage = 'Exception: File exceeds 5 MB limit';

      final message = await container
          .read(documentControllerProvider.notifier)
          .uploadDocument(filePath: '/cache/big.pdf', itemName: 'Big');

      expect(message, 'File exceeds the 5 MB limit.');
    });
  });
}
