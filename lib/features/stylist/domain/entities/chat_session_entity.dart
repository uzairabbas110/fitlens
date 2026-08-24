import 'chat_message_entity.dart';

class ChatSessionEntity {
  final String id;
  final String userId;
  final String title;
  final DateTime updatedAt;
  final List<ChatMessageEntity> messages;

  const ChatSessionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.updatedAt,
    required this.messages,
  });
}
