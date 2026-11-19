import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class ProfileRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  ProfileRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.requireUserId();

  Future<Map<String, dynamic>> loadProfile() async {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', _userId)
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    final payload = <String, dynamic>{'full_name': fullName};
    if (phoneNumber != null) payload['phone_number'] = phoneNumber;

    final response = await supabase
        .from('users')
        .update(payload)
        .eq('id', _userId)
        .select()
        .single();
    return response;
  }
}
