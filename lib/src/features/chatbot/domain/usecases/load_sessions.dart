import '../../../../core/errors/failures.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class LoadSessions {
  final ChatRepository repository;
  LoadSessions(this.repository);

  Future<Result<List<ChatSession>>> call() => repository.loadSessions();
}
