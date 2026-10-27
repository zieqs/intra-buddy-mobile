import 'package:url_launcher/url_launcher.dart';

/// Opens a signed document URL in the external browser.
///
/// Returns `false` when the scheme is not http(s) or the platform refuses to
/// open it, so callers can tell the user instead of failing silently.
Future<bool> openDocumentUrl(
  Uri uri, {
  Future<bool> Function(Uri uri)? launcher,
}) async {
  if (uri.scheme != 'https' && uri.scheme != 'http') return false;

  try {
    final launch =
        launcher ?? (u) => launchUrl(u, mode: LaunchMode.externalApplication);
    return await launch(uri);
  } catch (_) {
    return false;
  }
}
