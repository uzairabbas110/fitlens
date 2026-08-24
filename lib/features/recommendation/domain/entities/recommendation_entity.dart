/// Represents a complete outfit recommendation generated after analyzing
/// a clothing image.
///
/// This is a pure Dart object with no Flutter, TensorFlow Lite, or
/// Riverpod dependency, keeping the domain layer fully independent.
class RecommendationEntity {
  final String recommendedTop;
  final String recommendedBottom;
  final String recommendedFootwear;
  final String recommendedAccessory;
  final String styleDescription;
  final String colorHarmony;
  final String reason;
  final double confidence;

  const RecommendationEntity({
    required this.recommendedTop,
    required this.recommendedBottom,
    required this.recommendedFootwear,
    required this.recommendedAccessory,
    required this.styleDescription,
    required this.colorHarmony,
    required this.reason,
    required this.confidence,
  });

  /// Confidence expressed as a percentage (0-100).
  double get confidencePercentage => confidence * 100;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationEntity &&
        other.recommendedTop == recommendedTop &&
        other.recommendedBottom == recommendedBottom &&
        other.recommendedFootwear == recommendedFootwear &&
        other.recommendedAccessory == recommendedAccessory &&
        other.styleDescription == styleDescription &&
        other.colorHarmony == colorHarmony &&
        other.reason == reason &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
    recommendedTop,
    recommendedBottom,
    recommendedFootwear,
    recommendedAccessory,
    styleDescription,
    colorHarmony,
    reason,
    confidence,
  );

  @override
  String toString() =>
      'RecommendationEntity(recommendedTop: $recommendedTop, '
          'recommendedBottom: $recommendedBottom, '
          'recommendedFootwear: $recommendedFootwear, '
          'recommendedAccessory: $recommendedAccessory, '
          'styleDescription: $styleDescription, colorHarmony: $colorHarmony, '
          'reason: $reason, confidence: ${confidencePercentage.toStringAsFixed(1)}%)';
}