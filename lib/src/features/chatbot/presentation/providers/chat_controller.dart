import 'dart:async';
import 'dart:math';
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
  ref.watch(authUserIdProvider);
  final repo = ref.watch(chatRepositoryProvider);
  final result = await repo.loadMessages(sessionId);
  return result.fold((failure) => throw failure, (messages) => messages);
});

class SessionsNotifier extends AsyncNotifier<List<ChatSession>> {
  @override
  Future<List<ChatSession>> build() async {
    ref.watch(authUserIdProvider);
    final repo = ref.watch(chatRepositoryProvider);
    final result = await repo.loadSessions();
    return result.fold((failure) => throw failure, (sessions) => sessions);
  }

  Future<String> findOrCreateSession() async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.findOrCreateTodaySession();
    return result.fold((failure) => throw failure, (session) => session!.id);
  }

  Future<String> createNewSession() async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.createSession();
    final id = result.fold((failure) => throw failure, (session) => session.id);
    ref.invalidateSelf();
    return id;
  }

  Future<void> deleteSession(String id) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.deleteSession(id);
    ref.invalidateSelf();
  }
}

enum ChatProcessingPhase { idle, thinking, streaming }

class ChatProcessingState {
  final ChatProcessingPhase phase;
  final String? sessionId;
  final String? fullContent;

  const ChatProcessingState({
    this.phase = ChatProcessingPhase.idle,
    this.sessionId,
    this.fullContent,
  });

  static const idle = ChatProcessingState();
}

final chatControllerProvider =
    NotifierProvider<ChatController, ChatProcessingState>(ChatController.new);

class ChatController extends Notifier<ChatProcessingState> {
  Timer? _thinkingTimer;
  bool _disposed = false;

  @override
  ChatProcessingState build() {
    ref.watch(authUserIdProvider);
    ref.onDispose(() => _disposed = true);
    return const ChatProcessingState();
  }

  static const _fallbackMessage =
      "I'm sorry, I couldn't find an answer. Please try rephrasing or contact your coordinator.";

  Future<void> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    if (state.phase != ChatProcessingPhase.idle) return;

    final repo = ref.read(chatRepositoryProvider);

    await repo.addMessage(sessionId: sessionId, role: 'user', content: content);
    ref.invalidate(messagesProvider(sessionId));

    state = ChatProcessingState(
      phase: ChatProcessingPhase.thinking,
      sessionId: sessionId,
    );

    final answerResult = await repo.findAnswer(content);
    final answerText = answerResult.fold(
      (_) => _fallbackMessage,
      (faqMessage) => faqMessage?.content ?? _fallbackMessage,
    );

    if (_disposed || state.phase != ChatProcessingPhase.thinking) return;

    final delay = Duration(milliseconds: 800 + Random().nextInt(400));
    await Future.delayed(delay);

    if (_disposed || state.phase != ChatProcessingPhase.thinking) return;

    state = ChatProcessingState(
      phase: ChatProcessingPhase.streaming,
      sessionId: sessionId,
      fullContent: answerText,
    );
  }

  Future<void> completeStreaming() async {
    final currentState = state;
    if (currentState.phase != ChatProcessingPhase.streaming ||
        currentState.fullContent == null ||
        currentState.sessionId == null) {
      state = const ChatProcessingState();
      return;
    }

    final repo = ref.read(chatRepositoryProvider);
    await repo.addMessage(
      sessionId: currentState.sessionId!,
      role: 'assistant',
      content: currentState.fullContent!,
    );
    ref.invalidate(messagesProvider(currentState.sessionId!));
    state = const ChatProcessingState();
  }

  void stopStreaming() {
    if (state.phase == ChatProcessingPhase.thinking) {
      _thinkingTimer?.cancel();
      state = const ChatProcessingState();
      return;
    }
    if (state.phase == ChatProcessingPhase.streaming) {
      completeStreaming();
      return;
    }
  }

  void cancel() {
    _thinkingTimer?.cancel();
    state = const ChatProcessingState();
  }
}
