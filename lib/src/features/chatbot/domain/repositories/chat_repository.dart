import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<Result<List<ChatSession>>> loadSessions();
  Future<Result<ChatSession>> createSession();
  Future<Result<void>> deleteSession(String id);
  Future<Result<ChatSession?>> findOrCreateTodaySession();

  Future<Result<List<ChatMessage>>> loadMessages(String sessionId);
  Future<Result<ChatMessage>> addMessage({
    required String sessionId,
    required String role,
    required String content,
    int? matchedFaqId,
  });

  Future<Result<ChatMessage?>> findAnswer(String userMessage);
}
