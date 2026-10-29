/// What kind of in-app preview a document supports.
enum DocumentPreviewKind { pdf, image, unsupported }

DocumentPreviewKind previewKindFor(String? fileType) {
  switch (fileType?.trim().toLowerCase()) {
    case 'pdf':
      return DocumentPreviewKind.pdf;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
      return DocumentPreviewKind.image;
    default:
      return DocumentPreviewKind.unsupported;
  }
}
