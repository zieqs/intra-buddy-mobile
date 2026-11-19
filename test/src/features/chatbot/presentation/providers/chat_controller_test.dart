import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/auth_state_provider.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/domain/entities/chat_message.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/domain/entities/chat_session.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/presentation/providers/chat_controller.dart';

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.answer, this.answerFailure});

  ChatMessage? answer;
  Failure? answerFailure;
  final List<({String role, String content})> added = [];

  @override
  Future<Result<ChatMessage>> addMessage({
    required String sessionId,
    required String role,
    required String content,
    int? matchedFaqId,
  }) async {
    added.add((role: role, content: content));
    return Right(
      ChatMessage(
        id: added.length,
        sessionId: sessionId,
        role: role,
        content: content,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }

  @override
  Future<Result<ChatMessage?>> findAnswer(String userMessage) async {
    if (answerFailure != null) return Left(answerFailure!);
    return Right(answer);
  }

  @override
  Future<Result<List<ChatMessage>>> loadMessages(String sessionId) async =>
      const Right([]);

  @override
  Future<Result<List<ChatSession>>> loadSessions() async => const Right([]);

  @override
  Future<Result<ChatSession>> createSession() async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deleteSession(String id) async => const Right(null);

  @override
  Future<Result<ChatSession?>> findOrCreateTodaySession() async =>
      throw UnimplementedError();
}

ChatMessage _answer(String content) => ChatMessage(
  id: 99,
  sessionId: '',
  role: 'assistant',
  content: content,
  matchedFaqId: 3,
  createdAt: DateTime(2026, 1, 1),
);

ProviderContainer _container(_FakeChatRepository repository) {
  return ProviderContainer(
    overrides: [
      authUserIdProvider.overrideWithValue('student-1'),
      chatRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

void main() {
  group('ChatController', () {
    test('writes the user message, thinks, then streams the FAQ answer', () {
      fakeAsync((async) {
        final repository = _FakeChatRepository(
          answer: _answer('Submit it through the portal first.'),
        );
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(chatControllerProvider.notifier);

        controller.sendMessage(
          sessionId: 'session-1',
          content: 'How do I submit my logbook?',
        );
        async.flushMicrotasks();

        expect(repository.added.single.role, 'user');
        expect(
          container.read(chatControllerProvider).phase,
          ChatProcessingPhase.thinking,
        );

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        final state = container.read(chatControllerProvider);
        expect(state.phase, ChatProcessingPhase.streaming);
        expect(state.fullContent, 'Submit it through the portal first.');
      });
    });

    test('falls back to the coordinator message when the lookup fails', () {
      fakeAsync((async) {
        final repository = _FakeChatRepository(
          answerFailure: const ServerFailure('offline'),
        );
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(chatControllerProvider.notifier);

        controller.sendMessage(sessionId: 'session-1', content: 'anything');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        final state = container.read(chatControllerProvider);
        expect(state.phase, ChatProcessingPhase.streaming);
        expect(state.fullContent, contains("couldn't find an answer"));
      });
    });

    test('stores the streamed answer once streaming completes', () {
      fakeAsync((async) {
        final repository = _FakeChatRepository(answer: _answer('Answer'));
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(chatControllerProvider.notifier);

        controller.sendMessage(sessionId: 'session-1', content: 'question');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        controller.completeStreaming();
        async.flushMicrotasks();

        expect(repository.added.last.role, 'assistant');
        expect(repository.added.last.content, 'Answer');
        expect(
          container.read(chatControllerProvider).phase,
          ChatProcessingPhase.idle,
        );
      });
    });

    test('ignores a second send while the first is still thinking', () {
      fakeAsync((async) {
        final repository = _FakeChatRepository(answer: _answer('Answer'));
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(chatControllerProvider.notifier);

        controller.sendMessage(sessionId: 'session-1', content: 'first');
        async.flushMicrotasks();
        controller.sendMessage(sessionId: 'session-1', content: 'second');
        async.flushMicrotasks();

        expect(repository.added, hasLength(1));
        expect(repository.added.single.content, 'first');
        async.elapse(const Duration(seconds: 2));
      });
    });

    test('stopping while thinking leaves the conversation untouched', () {
      fakeAsync((async) {
        final repository = _FakeChatRepository(answer: _answer('Answer'));
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(chatControllerProvider.notifier);

        controller.sendMessage(sessionId: 'session-1', content: 'question');
        async.flushMicrotasks();
        controller.stopStreaming();

        expect(
          container.read(chatControllerProvider).phase,
          ChatProcessingPhase.idle,
        );

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(repository.added.where((m) => m.role == 'assistant'), isEmpty);
      });
    });
  });
}
