import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_session.dart';

part 'chat_session_model.g.dart';

@JsonSerializable()
class ChatSessionModel {
  final String id;
  final String? title;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ChatSessionModel({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);

  ChatSession toEntity() => ChatSession(
    id: id,
    title: title,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
