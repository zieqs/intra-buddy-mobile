import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/presentation/document_url_opener.dart';

void main() {
  test('opens an https URL and reports success', () async {
    Uri? opened;
    final result = await openDocumentUrl(
      Uri.parse('https://example.com/file.pdf'),
      launcher: (uri) async {
        opened = uri;
        return true;
      },
    );

    expect(result, isTrue);
    expect(opened, Uri.parse('https://example.com/file.pdf'));
  });

  test('opens an http URL', () async {
    final result = await openDocumentUrl(
      Uri.parse('http://example.com/file.pdf'),
      launcher: (_) async => true,
    );

    expect(result, isTrue);
  });

  test('refuses non-web schemes without calling the launcher', () async {
    var called = false;
    final result = await openDocumentUrl(
      Uri.parse('intent://evil'),
      launcher: (_) async {
        called = true;
        return true;
      },
    );

    expect(result, isFalse);
    expect(called, isFalse);
  });

  test('reports failure when the platform refuses to launch', () async {
    final result = await openDocumentUrl(
      Uri.parse('https://example.com/file.pdf'),
      launcher: (_) async => false,
    );

    expect(result, isFalse);
  });

  test('reports failure when the launcher throws', () async {
    final result = await openDocumentUrl(
      Uri.parse('https://example.com/file.pdf'),
      launcher: (_) async => throw Exception('no browser'),
    );

    expect(result, isFalse);
  });
}
