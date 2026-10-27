import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

/// Streams notification changes for the signed-in student.
abstract class NotificationRealtimeSource {
  /// Starts listening for inserts/updates/deletes affecting the current user.
  /// [onChange] is called whenever the inbox may have changed.
  void watch({required void Function() onChange});
}

/// Supabase Realtime implementation backed by Postgres Changes on
/// `public.notifications`, filtered to the signed-in student.
///
/// RLS still applies: the Realtime server only delivers rows the user is
/// allowed to select.
class SupabaseNotificationRealtimeSource implements NotificationRealtimeSource {
  SupabaseNotificationRealtimeSource(this.authService, this.supabase);

  final AuthService authService;
  final SupabaseClient supabase;
  RealtimeChannel? _channel;

  @override
  void watch({required void Function() onChange}) {
    _channel?.unsubscribe();
    _channel = null;

    final userId = authService.currentUser?.id;
    if (userId == null) return;

    final channel = supabase.channel('notifications:$userId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'recipient_id',
        value: userId,
      ),
      callback: (_) => onChange(),
    );
    channel.subscribe();
    _channel = channel;
  }

  Future<void> dispose() async {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await supabase.removeChannel(channel);
    }
  }
}
