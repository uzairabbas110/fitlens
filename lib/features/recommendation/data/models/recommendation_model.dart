import '../../domain/entities/recommendation_entity.dart';

/// Data-layer representation of [RecommendationEntity].
///
/// Adds JSON (de)serialization and entity conversion, which the domain
/// entity itself must remain free of. This keeps parsing concerns
/// isolated to the data layer, in line with Clean Architecture.
class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.recommendedTop,
    required super.recommendedBottom,
    required super.recommendedFootwear,
    required super.recommendedAccessory,
    required super.styleDescription,
    required super.colorHarmony,
    required super.reason,
    required super.confidence,
  });

  /// Builds a [RecommendationModel] from a JSON map.
  ///
  /// [confidence] is parsed safely regardless of whether the source value
  /// is encoded as an `int` or a `double`.
  static String _parseString(Map<String, dynamic> json, List<String> keys, String defaultVal) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        final v = json[key].toString().trim();
        if (v.isNotEmpty) return v;
      }
    }
    return defaultVal;
  }

  static double _parseDouble(dynamic val, double defaultVal) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) {
      final match = RegExp(r'[\d.]+').firstMatch(val)?.group(0);
      if (match != null) return double.tryParse(match) ?? defaultVal;
    }
    return defaultVal;
  }

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      recommendedTop: _parseString(json, ['recommendedTop', 'recommended_top', 'top'], 'Classic White Shirt / Oxford'),
      recommendedBottom: _parseString(json, ['recommendedBottom', 'recommended_bottom', 'bottom'], 'Tailored Slim Trousers'),
      recommendedFootwear: _parseString(json, ['recommendedFootwear', 'recommended_footwear', 'footwear', 'shoes'], 'Minimal Leather Sneakers'),
      recommendedAccessory: _parseString(json, ['recommendedAccessory', 'recommended_accessory', 'accessory'], 'Leather Watch'),
      styleDescription: _parseString(json, ['styleDescription', 'style_description', 'style'], 'Smart Casual'),
      colorHarmony: _parseString(json, ['colorHarmony', 'color_harmony', 'colors'], 'Monochromatic / Complementary'),
      reason: _parseString(json, ['reason', 'explanation', 'description'], 'Balanced silhouette and cohesive tones complement this item.'),
      confidence: _parseDouble(json['confidence'], 0.95),
    );
  }

  /// Converts this model into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'recommendedTop': recommendedTop,
      'recommendedBottom': recommendedBottom,
      'recommendedFootwear': recommendedFootwear,
      'recommendedAccessory': recommendedAccessory,
      'styleDescription': styleDescription,
      'colorHarmony': colorHarmony,
      'reason': reason,
      'confidence': confidence,
    };
  }

  /// Builds a [RecommendationModel] from a domain-layer
  /// [RecommendationEntity].
  factory RecommendationModel.fromEntity(RecommendationEntity entity) {
    return RecommendationModel(
      recommendedTop: entity.recommendedTop,
      recommendedBottom: entity.recommendedBottom,
      recommendedFootwear: entity.recommendedFootwear,
      recommendedAccessory: entity.recommendedAccessory,
      styleDescription: entity.styleDescription,
      colorHarmony: entity.colorHarmony,
      reason: entity.reason,
      confidence: entity.confidence,
    );
  }

  /// Returns this model as its underlying domain entity.
  RecommendationEntity toEntity() {
    return RecommendationEntity(
      recommendedTop: recommendedTop,
      recommendedBottom: recommendedBottom,
      recommendedFootwear: recommendedFootwear,
      recommendedAccessory: recommendedAccessory,
      styleDescription: styleDescription,
      colorHarmony: colorHarmony,
      reason: reason,
      confidence: confidence,
    );
  }
}