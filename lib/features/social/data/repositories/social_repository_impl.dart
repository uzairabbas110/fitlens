import '../../domain/entities/social_post_entity.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_data_source.dart';
import '../models/social_post_model.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<SocialPostEntity>> getGlobalFeed() {
    return remoteDataSource.getGlobalFeed();
  }

  @override
  Future<void> createPost(SocialPostEntity post) {
    final model = SocialPostModel.fromEntity(post);
    return remoteDataSource.createPost(model);
  }

  @override
  Future<void> likePost(String postId, String userId) {
    return remoteDataSource.likePost(postId, userId);
  }
}
