/// Represents the result of analyzing a clothing image.
///
/// This is a pure Domain Entity and has NO dependency on:
/// - Flutter
/// - Firebase
/// - Riverpod
/// - AI libraries
///
/// It only contains business data used throughout the application.
class AnalysisEntity {
  /// Type of clothing.
  ///
  /// Examples:
  /// - Shirt
  /// - T-Shirt
  /// - Jeans
  /// - Hoodie
  /// - Dress
  /// - Sneakers
  final String clothingType;

  /// Primary color of the clothing.
  ///
  /// Examples:
  /// - Black
  /// - White
  /// - Blue
  /// - Navy Blue
  /// - Red
  final String color;

  /// Pattern of the clothing.
  ///
  /// Examples:
  /// - Solid
  /// - Striped
  /// - Checked
  /// - Floral
  /// - Printed
  final String pattern;

  /// Material of the clothing.
  ///
  /// Examples:
  /// - Cotton
  /// - Denim
  /// - Polyester
  /// - Leather
  /// - Wool
  final String material;

  /// Suitable season.
  ///
  /// Examples:
  /// - Summer
  /// - Winter
  /// - Spring
  /// - Autumn
  /// - All Season
  final String season;

  /// Suitable occasion.
  ///
  /// Examples:
  /// - Casual
  /// - Formal
  /// - Party
  /// - Business
  /// - Sports
  final String occasion;

  /// AI confidence score.
  ///
  /// Must be between 0.0 and 1.0.
  final double confidence;

  const AnalysisEntity({
    required this.clothingType,
    required this.color,
    required this.pattern,
    required this.material,
    required this.season,
    required this.occasion,
    required this.confidence,
  }) : assert(
  confidence >= 0.0 && confidence <= 1.0,
  'Confidence must be between 0.0 and 1.0.',
  );

  /// Returns confidence as a percentage.
  double get confidencePercentage => confidence * 100;

  /// Creates a copy of this entity with updated values.
  AnalysisEntity copyWith({
    String? clothingType,
    String? color,
    String? pattern,
    String? material,
    String? season,
    String? occasion,
    double? confidence,
  }) {
    return AnalysisEntity(
      clothingType: clothingType ?? this.clothingType,
      color: color ?? this.color,
      pattern: pattern ?? this.pattern,
      material: material ?? this.material,
      season: season ?? this.season,
      occasion: occasion ?? this.occasion,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalysisEntity &&
        other.clothingType == clothingType &&
        other.color == color &&
        other.pattern == pattern &&
        other.material == material &&
        other.season == season &&
        other.occasion == occasion &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
    clothingType,
    color,
    pattern,
    material,
    season,
    occasion,
    confidence,
  );

  @override
  String toString() {
    return 'AnalysisEntity('
        'clothingType: $clothingType, '
        'color: $color, '
        'pattern: $pattern, '
        'material: $material, '
        'season: $season, '
        'occasion: $occasion, '
        'confidence: ${confidencePercentage.toStringAsFixed(1)}%'
        ')';
  }
}