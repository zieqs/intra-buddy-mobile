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

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
