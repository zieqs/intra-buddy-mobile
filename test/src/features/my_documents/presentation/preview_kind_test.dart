import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/my_documents/presentation/preview_kind.dart';

void main() {
  test('classifies pdf', () {
    expect(previewKindFor('pdf'), DocumentPreviewKind.pdf);
    expect(previewKindFor('PDF'), DocumentPreviewKind.pdf);
    expect(previewKindFor(' pdf '), DocumentPreviewKind.pdf);
  });

  test('classifies images', () {
    for (final type in ['jpg', 'jpeg', 'png', 'gif', 'webp', 'JPG']) {
      expect(previewKindFor(type), DocumentPreviewKind.image, reason: type);
    }
  });

  test('classifies everything else as unsupported', () {
    for (final type in ['doc', 'docx', 'xlsx', null, '', 'pdfx']) {
      expect(
        previewKindFor(type),
        DocumentPreviewKind.unsupported,
        reason: '$type',
      );
    }
  });
}
