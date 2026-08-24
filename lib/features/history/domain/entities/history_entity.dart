/// Represents a single saved history record containing both the clothing
/// analysis result and the AI-generated outfit recommendation for a
/// single image.
///
/// Each history record belongs to one authenticated user and is intended
/// to be persisted in Firestore. This entity is a pure Dart object with
/// no dependency on Flutter, Firebase, or Riverpod, keeping the domain
/// layer completely independent.
class HistoryEntity {
  final String id;
  final String userId;
  final String feature;
  final String? userImagePath;
  final String? clothingImagePath;

  final String skinTone;
  final String estimatedSize;
  final String recommendedSize;
  final int sizeMatchScore;
  final int colorMatchScore;
  final String clothingTexture;
  final String clothingQuality;
  final int qualityScore;
  final String buyAdvice;
  final String reasoning;
  
  final DateTime createdAt;

  const HistoryEntity({
    required this.id,
    required this.userId,
    required this.feature,
    this.userImagePath,
    this.clothingImagePath,
    required this.skinTone,
    required this.estimatedSize,
    required this.recommendedSize,
    required this.sizeMatchScore,
    required this.colorMatchScore,
    required this.clothingTexture,
    required this.clothingQuality,
    required this.qualityScore,
    required this.buyAdvice,
    required this.reasoning,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryEntity &&
        other.id == id &&
        other.userId == userId &&
        other.feature == feature &&
        other.userImagePath == userImagePath &&
        other.clothingImagePath == clothingImagePath &&
        other.skinTone == skinTone &&
        other.estimatedSize == estimatedSize &&
        other.recommendedSize == recommendedSize &&
        other.sizeMatchScore == sizeMatchScore &&
        other.colorMatchScore == colorMatchScore &&
        other.clothingTexture == clothingTexture &&
        other.clothingQuality == clothingQuality &&
        other.qualityScore == qualityScore &&
        other.buyAdvice == buyAdvice &&
        other.reasoning == reasoning &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    feature,
    userImagePath,
    clothingImagePath,
    skinTone,
    estimatedSize,
    recommendedSize,
    sizeMatchScore,
    colorMatchScore,
    clothingTexture,
    clothingQuality,
    qualityScore,
    buyAdvice,
    reasoning,
    createdAt,
  );

  @override
  String toString() {
    return 'HistoryEntity('
        'id: $id, '
        'userId: $userId, '
        'feature: $feature, '
        'skinTone: $skinTone, '
        'buyAdvice: $buyAdvice'
        ')';
  }
}