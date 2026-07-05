import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<ChatSession>>> loadSessions() async {
    try {
      final data = await dataSource.loadSessions();
      final sessions = data
          .map((json) => ChatSessionModel.fromJson(json))
          .toList();
      return Right(sessions.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatSession>> createSession() async {
    try {
      final data = await dataSource.createSession();
      return Right(ChatSessionModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSession(String id) async {
    try {
      await dataSource.deleteSession(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatSession?>> findOrCreateTodaySession() async {
    try {
      final sessions = await dataSource.loadSessions();
      if (sessions.isNotEmpty) {
        return Right(ChatSessionModel.fromJson(sessions.first).toEntity());
      }
      final created = await dataSource.createSession();
      return Right(ChatSessionModel.fromJson(created).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ChatMessage>>> loadMessages(String sessionId) async {
    try {
      final data = await dataSource.loadMessages(sessionId);
      final messages = data
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
      return Right(messages.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatMessage>> addMessage({
    required String sessionId,
    required String role,
    required String content,
    int? matchedFaqId,
  }) async {
    try {
      final data = await dataSource.addMessage(
        sessionId: sessionId,
        role: role,
        content: content,
        matchedFaqId: matchedFaqId,
      );
      return Right(ChatMessageModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatMessage?>> findAnswer(String userMessage) async {
    try {
      final match = await dataSource.findAnswer(userMessage);
      if (match == null) return const Right(null);

      return Right(
        ChatMessage(
          id: 0,
          sessionId: '',
          role: 'assistant',
          content: match['answer'] as String,
          matchedFaqId: match['id'] as int?,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
