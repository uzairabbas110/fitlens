import '../entities/chat_session_entity.dart';

abstract class StylistRepository {
  Future<List<ChatSessionEntity>> getUserSessions(String userId);
  Future<void> saveSession(ChatSessionEntity session);
  Future<void> deleteSession(String sessionId);
}
