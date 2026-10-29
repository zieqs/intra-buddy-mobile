import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/presentation/save_document.dart';

void main() {
  group('downloadFileName', () {
    test('keeps a name that already has the extension', () {
      expect(
        downloadFileName('Resume October 2026.pdf', 'pdf'),
        'Resume October 2026.pdf',
      );
    });

    test('appends the extension when missing', () {
      expect(downloadFileName('CV', 'pdf'), 'CV.pdf');
    });

    test('does not duplicate the extension regardless of case', () {
      expect(downloadFileName('CV.PDF', 'pdf'), 'CV.PDF');
    });

    test('falls back to document when the name is blank', () {
      expect(downloadFileName('   ', 'pdf'), 'document.pdf');
    });

    test('strips path separators', () {
      expect(downloadFileName('a/b\\c.pdf', 'pdf'), 'a_b_c.pdf');
    });

    test('leaves the name alone when there is no file type', () {
      expect(downloadFileName('CV', null), 'CV');
    });
  });

  group('saveDocumentToDevice', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('reports saved when the picker returns a path', () async {
      final outcome = await saveDocumentToDevice(
        fileName: 'CV.pdf',
        bytes: bytes,
        saver: (_, _) async => '/Downloads/CV.pdf',
      );

      expect(outcome, SaveOutcome.saved);
    });

    test('reports cancelled when the picker returns null', () async {
      final outcome = await saveDocumentToDevice(
        fileName: 'CV.pdf',
        bytes: bytes,
        saver: (_, _) async => null,
      );

      expect(outcome, SaveOutcome.cancelled);
    });

    test('reports failed when the picker throws', () async {
      final outcome = await saveDocumentToDevice(
        fileName: 'CV.pdf',
        bytes: bytes,
        saver: (_, _) async => throw Exception('no access'),
      );

      expect(outcome, SaveOutcome.failed);
    });

    test('passes the normalised name and the bytes to the saver', () async {
      String? seenName;
      Uint8List? seenBytes;

      await saveDocumentToDevice(
        fileName: 'CV.pdf',
        bytes: bytes,
        saver: (name, data) async {
          seenName = name;
          seenBytes = data;
          return '/Downloads/CV.pdf';
        },
      );

      expect(seenName, 'CV.pdf');
      expect(seenBytes, bytes);
    });
  });

  group('saveOutcomeMessage', () {
    test('describes each outcome', () {
      expect(saveOutcomeMessage(SaveOutcome.saved), 'Saved to your device');
      expect(saveOutcomeMessage(SaveOutcome.cancelled), 'Download cancelled');
      expect(
        saveOutcomeMessage(SaveOutcome.failed),
        'Could not save the document',
      );
    });
  });
}
