import '../entities/social_post_entity.dart';

abstract class SocialRepository {
  Stream<List<SocialPostEntity>> getGlobalFeed();
  Future<void> createPost(SocialPostEntity post);
  Future<void> likePost(String postId, String userId);
}
