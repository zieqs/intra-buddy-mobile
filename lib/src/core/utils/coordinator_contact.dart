import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';

/// Reads `COORDINATOR_CONTACT` from the environment, if dotenv has been
/// loaded. Returns null otherwise, so screens still build in tests.
Uri? configuredCoordinatorContact() {
  if (!dotenv.isInitialized) return null;
  return parseCoordinatorContact(
    dotenv.env[AppConstants.coordinatorContactKey],
  );
}

/// Parses the `COORDINATOR_CONTACT` value into something `url_launcher` can
/// open.
///
/// Accepts an email address, a full URL, or a phone number (treated as a
/// WhatsApp link). Returns null when nothing is configured.
Uri? parseCoordinatorContact(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;

  if (value.contains('://') || value.startsWith('mailto:')) {
    return Uri.tryParse(value);
  }

  if (value.contains('@')) {
    return Uri(scheme: 'mailto', path: value);
  }

  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return Uri.parse('https://wa.me/$digits');
}
