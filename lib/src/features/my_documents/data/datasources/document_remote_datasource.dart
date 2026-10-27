import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';
import 'document_storage_path.dart';

class DocumentRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  DocumentRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

  Future<List<Map<String, dynamic>>> loadDocuments() async {
    return supabase
        .from('digital_wallet_items')
        .select()
        .eq('student_id', _userId)
        .order('uploaded_at', ascending: false);
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String itemName,
    String? notes,
  }) async {
    final file = File(filePath);
    final fileSize = await file.length();
    if (fileSize > AppConstants.uploadMaxBytes) {
      throw Exception('File exceeds 5 MB limit');
    }

    final ext = filePath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = documentStoragePath(
      userId: _userId,
      filePath: filePath,
      timestamp: timestamp,
    );

    await supabase.storage
        .from('student-documents')
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final response = await supabase
        .from('digital_wallet_items')
        .insert({
          'student_id': _userId,
          'item_name': itemName,
          'file_path': storagePath,
          'file_type': ext,
          'notes': notes,
        })
        .select()
        .single();

    return response;
  }

  Future<String> getViewUrl(String storagePath) async {
    final response = await supabase.storage
        .from('student-documents')
        .createSignedUrl(storagePath, 300);
    return response;
  }

  Future<void> deleteDocument(int id, String storagePath) async {
    await supabase.storage.from('student-documents').remove([storagePath]);
    await supabase.from('digital_wallet_items').delete().eq('id', id);
  }
}
