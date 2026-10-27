/// Storage object key for a student document.
///
/// The bucket name is **not** part of the key: `StorageFileApi` already builds
/// `/object/{bucketId}/{path}`, and the storage RLS policies expect the first
/// path segment to be the student's id. Prefixing `student-documents/` here
/// makes the first segment the bucket name and every upload fails RLS.
String documentStoragePath({
  required String userId,
  required String filePath,
  required int timestamp,
}) {
  final fileName = filePath.split(RegExp(r'[/\\]')).last;
  final dot = fileName.lastIndexOf('.');
  final hasExtension = dot > 0 && dot < fileName.length - 1;
  final extension = hasExtension
      ? fileName.substring(dot + 1).toLowerCase()
      : 'bin';

  return '$userId/$timestamp.$extension';
}
