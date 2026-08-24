import '../../domain/entities/chat_session_entity.dart';
import 'chat_message_model.dart';

class ChatSessionModel extends ChatSessionEntity {
  const ChatSessionModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.updatedAt,
    required super.messages,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) {
        if (m is ChatMessageModel) {
          return m.toJson();
        }
        return ChatMessageModel(
          id: m.id,
          text: m.text,
          isUser: m.isUser,
          imageUrl: m.imageUrl,
          timestamp: m.timestamp,
        ).toJson();
      }).toList(),
    };
  }
}
