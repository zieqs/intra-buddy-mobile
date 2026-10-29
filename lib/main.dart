import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/constants/app_constants.dart';
import 'src/app/intra_buddy_app.dart';
import 'src/features/logbook/presentation/services/logbook_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey];
  final supabaseAnonKey = dotenv.env[AppConstants.supabaseAnonKeyKey];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw StateError('Missing SUPABASE_URL in .env');
  }
  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  try {
    await LogbookReminderService.instance.init();
  } catch (_) {
    // Notifications are unavailable on this platform; the app still works.
  }

  runApp(const ProviderScope(child: IntraBuddyApp()));
}
