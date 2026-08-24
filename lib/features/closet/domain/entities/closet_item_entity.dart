class ClosetItemEntity {
  final String id;
  final String userId;
  final String imageUrl;
  final String category;
  final String color;
  final String season;
  final DateTime dateAdded;

  const ClosetItemEntity({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.category,
    required this.color,
    required this.season,
    required this.dateAdded,
  });
}
