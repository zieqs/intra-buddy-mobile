class ChatMessage {
  final int id;
  final String sessionId;
  final String role;
  final String content;
  final int? matchedFaqId;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.matchedFaqId,
    required this.createdAt,
  });
}
