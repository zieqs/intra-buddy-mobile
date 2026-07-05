import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class ChatRemoteDataSource {
  final AuthService authService;
  final SupabaseClient supabase;

  ChatRemoteDataSource(this.authService, this.supabase);

  String get _userId => authService.currentUser!.id;

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

    await supabase
        .from('chat_sessions')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', sessionId);

    final response = await supabase
        .from('chat_messages')
        .insert(payload)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>?> findAnswer(String userMessage) async {
    final faqs = await supabase
        .from('faqs')
        .select('id, question, answer, keywords')
        .eq('is_published', true);

    Map<String, dynamic>? bestMatch;
    var bestScore = 0;

    final userWords = userMessage
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .toSet();

    for (final faq in faqs) {
      var score = 0;
      final title = (faq['question'] as String).toLowerCase();

      if (userMessage.toLowerCase().contains(title)) {
        score += 10;
      }

      final keywords =
          (faq['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          [];

      for (final keyword in keywords) {
        if (userMessage.toLowerCase().contains(keyword)) {
          score += 5;
        }
      }

      final faqWords = title
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 3)
          .toSet();
      final overlap = userWords.intersection(faqWords);
      score += overlap.length;

      if (score > bestScore) {
        bestScore = score;
        bestMatch = faq;
      }
    }

    if (bestMatch != null && bestScore > 0) {
      return bestMatch;
    }
    return null;
  }
}
