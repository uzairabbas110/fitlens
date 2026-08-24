class SocialPostEntity {
  final String id;
  final String userId;
  final String username;
  final String imageUrl;
  final String description;
  final int likesCount;
  final DateTime timestamp;

  const SocialPostEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.imageUrl,
    required this.description,
    required this.likesCount,
    required this.timestamp,
  });
}
