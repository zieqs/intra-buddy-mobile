import 'package:flutter/foundation.dart' show Uint8List;
import '../../../../core/errors/failures.dart';
import '../entities/document_item.dart';

abstract class DocumentRepository {
  Future<Result<List<DocumentItem>>> loadDocuments();
  Future<Result<Uint8List>> downloadDocument(String storagePath);
  Future<Result<DocumentItem>> uploadDocument({
    required String filePath,
    required String itemName,
    String? notes,
  });
  Future<Result<String>> getViewUrl(String storagePath);
  Future<Result<void>> deleteDocument(int id, String storagePath);
}
