class ChatSession {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });
}
