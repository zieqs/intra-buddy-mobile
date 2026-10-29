import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

enum SaveOutcome { saved, cancelled, failed }

String saveOutcomeMessage(SaveOutcome outcome) => switch (outcome) {
  SaveOutcome.saved => 'Saved to your device',
  SaveOutcome.cancelled => 'Download cancelled',
  SaveOutcome.failed => 'Could not save the document',
};

/// Builds a safe file name for the system "Save to…" picker.
String downloadFileName(String itemName, String? fileType) {
  final base = itemName.trim().replaceAll(RegExp(r'[/\\]'), '_');
  final safeBase = base.isEmpty ? 'document' : base;

  final type = fileType?.trim().toLowerCase();
  if (type == null || type.isEmpty) return safeBase;
  if (safeBase.toLowerCase().endsWith('.$type')) return safeBase;

  return '$safeBase.$type';
}

/// Opens the system save dialog and writes [bytes] there.
///
/// Uses [FilePicker.saveFile], which on Android/iOS is the SAF/document picker
/// and needs no storage permission.
Future<SaveOutcome> saveDocumentToDevice({
  required String fileName,
  required Uint8List bytes,
  Future<String?> Function(String fileName, Uint8List bytes)? saver,
}) async {
  try {
    final save =
        saver ??
        (name, data) => FilePicker.saveFile(
          dialogTitle: 'Save document',
          fileName: name,
          bytes: data,
        );

    final path = await save(fileName, bytes);
    return path == null ? SaveOutcome.cancelled : SaveOutcome.saved;
  } catch (_) {
    return SaveOutcome.failed;
  }
}
