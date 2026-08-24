import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session_model.dart';

abstract class StylistRemoteDataSource {
  Future<List<ChatSessionModel>> getUserSessions(String userId);
  Future<void> saveSession(ChatSessionModel session);
  Future<void> deleteSession(String sessionId);
}

class StylistRemoteDataSourceImpl implements StylistRemoteDataSource {
  final FirebaseFirestore _firestore;

  StylistRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ChatSessionModel>> getUserSessions(String userId) async {
    final snapshot = await _firestore
        .collection('stylist_chats')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChatSessionModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> saveSession(ChatSessionModel session) async {
    await _firestore
        .collection('stylist_chats')
        .doc(session.id)
        .set(session.toJson());
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection('stylist_chats').doc(sessionId).delete();
  }
}
