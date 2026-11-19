import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/match_faq.dart';

class ChatRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  ChatRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.requireUserId();

  Future<List<Map<String, dynamic>>> loadSessions() async {
    return supabase
        .from('chat_sessions')
        .select()
        .eq('student_id', _userId)
        .order('updated_at', ascending: false);
  }

  Future<Map<String, dynamic>> createSession() async {
    final response = await supabase
        .from('chat_sessions')
        .insert({'student_id': _userId})
        .select()
        .single();
    return response;
  }

  Future<void> deleteSession(String id) async {
    await supabase.from('chat_messages').delete().eq('session_id', id);
    await supabase.from('chat_sessions').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> loadMessages(String sessionId) async {
    return supabase
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
  }

  Future<Map<String, dynamic>> addMessage({
    required String sessionId,
    required String role,
    required String content,
    int? matchedFaqId,
  }) async {
    final payload = <String, dynamic>{
      'session_id': sessionId,
      'role': role,
      'content': content,
    };
    if (matchedFaqId != null) payload['matched_faq_id'] = matchedFaqId;

    final now = DateTime.now().toIso8601String();
    await supabase
        .from('chat_sessions')
        .update({'updated_at': now})
        .eq('id', sessionId);

    if (role == 'user') {
      final snippet = content.length > 60
          ? '${content.substring(0, 57)}...'
          : content;
      await supabase
          .from('chat_sessions')
          .update({'title': snippet})
          .eq('id', sessionId)
          .filter('title', 'is', 'null');
    }

    final response = await supabase
        .from('chat_messages')
        .insert(payload)
        .select()
        .single();
    return response;
  }

  Future<FaqEntry?> findAnswer(String userMessage) async {
    final faqs = await supabase
        .from('faqs')
        .select('id, question, answer, keywords')
        .eq('is_published', true);

    return matchFaq(
      userMessage,
      faqs
          .map(
            (faq) => FaqEntry(
              id: faq['id'] as int,
              question: faq['question'] as String,
              answer: faq['answer'] as String,
              keywords:
                  (faq['keywords'] as List<dynamic>?)
                      ?.map((keyword) => keyword.toString())
                      .toList() ??
                  const [],
            ),
          )
          .toList(),
    );
  }
}
