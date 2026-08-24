import '../../domain/entities/analysis_entity.dart';

/// Data-layer representation of [AnalysisEntity].
///
/// Adds JSON (de)serialization and entity conversion, which the domain
/// entity itself must remain free of. This keeps parsing concerns
/// isolated to the data layer, in line with Clean Architecture.
class AnalysisModel extends AnalysisEntity {
  const AnalysisModel({
    required super.clothingType,
    required super.color,
    required super.pattern,
    required super.material,
    required super.season,
    required super.occasion,
    required super.confidence,
  });

  /// Builds an [AnalysisModel] from a JSON map.
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

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      clothingType: _parseString(json, ['clothingType', 'clothing_type', 'type', 'item'], 'Casual Top'),
      color: _parseString(json, ['color', 'primary_color', 'shade'], 'Neutral'),
      pattern: _parseString(json, ['pattern', 'print', 'texture_pattern'], 'Solid'),
      material: _parseString(json, ['material', 'fabric'], 'Cotton Blend'),
      season: _parseString(json, ['season', 'suitable_season'], 'All-Season'),
      occasion: _parseString(json, ['occasion', 'suitable_occasion'], 'Casual'),
      confidence: _parseDouble(json['confidence'], 0.95),
    );
  }

  /// Converts this model into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'clothingType': clothingType,
      'color': color,
      'pattern': pattern,
      'material': material,
      'season': season,
      'occasion': occasion,
      'confidence': confidence,
    };
  }

  /// Builds an [AnalysisModel] from a domain-layer [AnalysisEntity].
  factory AnalysisModel.fromEntity(AnalysisEntity entity) {
    return AnalysisModel(
      clothingType: entity.clothingType,
      color: entity.color,
      pattern: entity.pattern,
      material: entity.material,
      season: entity.season,
      occasion: entity.occasion,
      confidence: entity.confidence,
    );
  }

  /// Returns this model as its underlying domain entity.
  AnalysisEntity toEntity() {
    return AnalysisEntity(
      clothingType: clothingType,
      color: color,
      pattern: pattern,
      material: material,
      season: season,
      occasion: occasion,
      confidence: confidence,
    );
  }
}