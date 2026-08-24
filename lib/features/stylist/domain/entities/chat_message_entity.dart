class ChatMessageEntity {
  final String id;
  final String text;
  final bool isUser;
  final String? imageUrl;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.isUser,
    this.imageUrl,
    required this.timestamp,
  });
}
