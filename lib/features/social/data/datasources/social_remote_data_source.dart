import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_post_model.dart';

abstract class SocialRemoteDataSource {
  Stream<List<SocialPostModel>> getGlobalFeed();
  Future<void> createPost(SocialPostModel post);
  Future<void> likePost(String postId, String userId);
}

class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final FirebaseFirestore _firestore;

  SocialRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<SocialPostModel>> getGlobalFeed() {
    return _firestore
        .collection('social_posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return SocialPostModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> createPost(SocialPostModel post) async {
    final collection = _firestore.collection('social_posts');
    if (post.id.isEmpty) {
      final docRef = collection.doc();
      final postWithId = SocialPostModel(
        id: docRef.id,
        userId: post.userId,
        username: post.username,
        imageUrl: post.imageUrl,
        description: post.description,
        likesCount: post.likesCount,
        timestamp: post.timestamp,
      );
      await docRef.set(postWithId.toJson());
    } else {
      await collection.doc(post.id).set(post.toJson());
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final docRef = _firestore.collection('social_posts').doc(postId);
    await docRef.update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }
}
