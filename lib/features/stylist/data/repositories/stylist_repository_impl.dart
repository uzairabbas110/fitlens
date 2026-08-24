import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/stylist_repository.dart';
import '../datasources/stylist_remote_data_source.dart';
import '../models/chat_session_model.dart';

class StylistRepositoryImpl implements StylistRepository {
  final StylistRemoteDataSource remoteDataSource;

  StylistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatSessionEntity>> getUserSessions(String userId) async {
    return await remoteDataSource.getUserSessions(userId);
  }

  @override
  Future<void> saveSession(ChatSessionEntity session) async {
    final model = ChatSessionModel(
      id: session.id,
      userId: session.userId,
      title: session.title,
      updatedAt: session.updatedAt,
      messages: session.messages,
    );
    await remoteDataSource.saveSession(model);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await remoteDataSource.deleteSession(sessionId);
  }
}
