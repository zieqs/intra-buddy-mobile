import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource dataSource;

  DocumentRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<DocumentItem>>> loadDocuments() async {
    try {
      final data = await dataSource.loadDocuments();
      final items = data.map((json) => DocumentModel.fromJson(json)).toList();
      return Right(items.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Uint8List>> downloadDocument(String storagePath) async {
    try {
      final bytes = await dataSource.downloadDocument(storagePath);
      return Right(bytes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<DocumentItem>> uploadDocument({
    required String filePath,
    required String itemName,
    String? notes,
  }) async {
    try {
      final data = await dataSource.uploadDocument(
        filePath: filePath,
        itemName: itemName,
        notes: notes,
      );
      return Right(DocumentModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> renameDocument(int id, String itemName) async {
    try {
      await dataSource.renameDocument(id, itemName);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteDocument(int id, String storagePath) async {
    try {
      await dataSource.deleteDocument(id, storagePath);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
