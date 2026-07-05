class AppNotification {
  final int id;
  final String? title;
  final String? body;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    this.title,
    this.body,
    this.type,
    required this.isRead,
    required this.createdAt,
  });
}
