import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the main manifest declares the INTERNET permission', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    // Debug and profile builds inject INTERNET from their own manifests for
    // the Flutter tool, which hides a release-only failure from every normal
    // Flutter check. A release APK without this cannot reach Supabase.
    expect(
      manifest,
      contains('android.permission.INTERNET'),
      reason:
          'Release builds do not inherit debug/profile permissions. '
          'Add android.permission.INTERNET to the main manifest.',
    );
  });
}
