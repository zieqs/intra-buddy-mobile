import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/providers/auth_state_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return ChatRepositoryImpl(ChatRemoteDataSource(authService, supabase));
});

final sessionsProvider =
    AsyncNotifierProvider<SessionsNotifier, List<ChatSession>>(
      SessionsNotifier.new,
    );

final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  sessionId,
) async {
  final repo = ref.watch(chatRepositoryProvider);
  final result = await repo.loadMessages(sessionId);
  return result.fold((failure) => throw failure, (messages) => messages);
});

class SessionsNotifier extends AsyncNotifier<List<ChatSession>> {
  @override
  Future<List<ChatSession>> build() async {
    final repo = ref.watch(chatRepositoryProvider);
    final result = await repo.loadSessions();
    return result.fold((failure) => throw failure, (sessions) => sessions);
  }

  Future<String> findOrCreateSession() async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.findOrCreateTodaySession();
    return result.fold((failure) => throw failure, (session) => session!.id);
  }

  Future<void> deleteSession(String id) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.deleteSession(id);
    ref.invalidateSelf();
  }
}

final chatControllerProvider = Provider<ChatController>(
  (ref) => ChatController(ref),
);

class ChatController {
  final Ref _ref;

  ChatController(this._ref);

  Future<void> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    final repo = _ref.read(chatRepositoryProvider);

    await repo.addMessage(sessionId: sessionId, role: 'user', content: content);

    final answer = await repo.findAnswer(content);
    answer.fold((_) {}, (faqMessage) async {
      if (faqMessage != null) {
        await repo.addMessage(
          sessionId: sessionId,
          role: 'assistant',
          content: faqMessage.content,
          matchedFaqId: faqMessage.matchedFaqId,
        );
      } else {
        await repo.addMessage(
          sessionId: sessionId,
          role: 'assistant',
          content:
              "I'm sorry, I couldn't find an answer. Please try rephrasing or contact your coordinator.",
        );
      }
      _ref.invalidate(messagesProvider(sessionId));
    });

    _ref.invalidate(messagesProvider(sessionId));
  }
}
