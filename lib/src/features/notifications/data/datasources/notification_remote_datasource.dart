import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class NotificationRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  NotificationRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

  Future<List<Map<String, dynamic>>> loadNotifications() async {
    return supabase
        .from('notifications')
        .select()
        .eq('recipient_id', _userId)
        .isFilter('archived_at', null)
        .order('created_at', ascending: false);
  }

  Future<void> markAllAsRead() async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('recipient_id', _userId)
        .eq('is_read', false);
  }

  Future<void> markAsRead(int id) async {
    await supabase.from('notifications').update({'is_read': true}).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> archiveReadNotifications() {
    return supabase
        .from('notifications')
        .update({'archived_at': DateTime.now().toIso8601String()})
        .eq('is_read', true)
        .isFilter('archived_at', null)
        .select('id');
  }

  Future<List<Map<String, dynamic>>> archiveNotification(int id) {
    return supabase
        .from('notifications')
        .update({'archived_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .isFilter('archived_at', null)
        .select('id');
  }
}
