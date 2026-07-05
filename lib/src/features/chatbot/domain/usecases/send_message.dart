import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<Result<ChatMessage>> call({
    required String sessionId,
    required String content,
  }) async {
    final userMsg = await repository.addMessage(
      sessionId: sessionId,
      role: 'user',
      content: content,
    );

    return userMsg.fold((failure) => Left(failure), (_) async {
      final answer = await repository.findAnswer(content);
      return answer.fold((failure) => Left(failure), (faqMessage) async {
        if (faqMessage != null) {
          return Right(faqMessage);
        }
        final fallback = await repository.addMessage(
          sessionId: sessionId,
          role: 'assistant',
          content:
              "I'm sorry, I couldn't find an answer to your question. Please try rephrasing or contact your coordinator.",
        );
        return fallback;
      });
    });
  }
}
