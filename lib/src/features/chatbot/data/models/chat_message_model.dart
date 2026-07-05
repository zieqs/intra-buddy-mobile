import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@JsonSerializable()
class ChatMessageModel {
  final int id;

  @JsonKey(name: 'session_id')
  final String sessionId;

  final String role;
  final String content;

  @JsonKey(name: 'matched_faq_id')
  final int? matchedFaqId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.matchedFaqId,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  ChatMessage toEntity() => ChatMessage(
    id: id,
    sessionId: sessionId,
    role: role,
    content: content,
    matchedFaqId: matchedFaqId,
    createdAt: createdAt,
  );
}
