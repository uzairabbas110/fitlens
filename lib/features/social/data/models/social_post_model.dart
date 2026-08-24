import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/social_post_entity.dart';

class SocialPostModel extends SocialPostEntity {
  const SocialPostModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.imageUrl,
    required super.description,
    required super.likesCount,
    required super.timestamp,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    int parsedLikesCount = 0;
    if (json['likes'] != null) {
      parsedLikesCount = (json['likes'] as List).length;
    } else if (json['likesCount'] != null) {
      parsedLikesCount = json['likesCount'] as int;
    }

    return SocialPostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      likesCount: parsedLikesCount,
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'imageUrl': imageUrl,
      'description': description,
      'likesCount': likesCount,
      'likes': [], // Initialize with empty array for new posts
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory SocialPostModel.fromEntity(SocialPostEntity entity) {
    return SocialPostModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      imageUrl: entity.imageUrl,
      description: entity.description,
      likesCount: entity.likesCount,
      timestamp: entity.timestamp,
    );
  }
}
