import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/data/datasources/document_storage_path.dart';

void main() {
  test('builds a path relative to the bucket', () {
    final path = documentStoragePath(
      userId: 'uid-1',
      filePath: '/cache/file_picker/CV.pdf',
      timestamp: 1700000000000,
    );

    expect(path, 'uid-1/1700000000000.pdf');
  });

  test('never prefixes the bucket name (it is already in .from())', () {
    final path = documentStoragePath(
      userId: 'uid-1',
      filePath: '/cache/CV.pdf',
      timestamp: 1,
    );

    expect(path.startsWith('student-documents/'), isFalse);
  });

  test('lowercases the extension', () {
    final path = documentStoragePath(
      userId: 'uid-1',
      filePath: '/cache/CV.PDF',
      timestamp: 1,
    );

    expect(path, 'uid-1/1.pdf');
  });

  test('uses the last extension for files with multiple dots', () {
    final path = documentStoragePath(
      userId: 'uid-1',
      filePath: '/cache/my.cv.final.pdf',
      timestamp: 1,
    );

    expect(path, 'uid-1/1.pdf');
  });

  test('falls back to bin when there is no extension', () {
    final path = documentStoragePath(
      userId: 'uid-1',
      filePath: '/cache/offer-letter',
      timestamp: 1,
    );

    expect(path, 'uid-1/1.bin');
  });
}
