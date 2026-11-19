import 'package:flutter/foundation.dart';

/// Minimal logging seam for failures the app recovers from.
///
/// Debug builds print to the console so a swallowed exception is still
/// diagnosable. Release builds are intentionally silent; when a crash reporter
/// (Sentry, Crashlytics) is added, forward these calls from [_write] instead of
/// sprinkling platform code through the features.
class AppLogger {
  AppLogger._();

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _write('WARN', message, error, stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _write('ERROR', message, error, stackTrace);
  }

  static void _write(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!kDebugMode) return;

    debugPrint('[INTRA Buddy][$level] $message');
    if (error != null) debugPrint('  $error');
    if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
  }
}
