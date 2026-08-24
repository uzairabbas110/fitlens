import '../../domain/entities/dashboard_result_entity.dart';

class FitLensResultModel extends FitLensResultEntity {
  const FitLensResultModel({
    required super.skinTone,
    required super.estimatedSize,
    required super.recommendedSize,
    required super.sizeMatchScore,
    required super.colorMatchScore,
    required super.qualityScore,
    required super.clothingTexture,
    required super.clothingQuality,
    required super.buyAdvice,
    required super.reasoning,
  });

  static int _parseInt(dynamic val, int defaultVal) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) {
      final digits = RegExp(r'\d+').firstMatch(val)?.group(0);
      if (digits != null) return int.tryParse(digits) ?? defaultVal;
    }
    return defaultVal;
  }

  static String _parseString(Map<String, dynamic> json, List<String> keys, String defaultVal) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        final v = json[key].toString().trim();
        if (v.isNotEmpty) return v;
      }
    }
    return defaultVal;
  }

  factory FitLensResultModel.fromJson(Map<String, dynamic> json) {
    return FitLensResultModel(
      skinTone: _parseString(json, ['skinTone', 'skin_tone', 'skintone'], 'Warm / Natural'),
      estimatedSize: _parseString(json, ['estimatedSize', 'estimated_size', 'body_size', 'size'], 'Medium (M)'),
      recommendedSize: _parseString(json, ['recommendedSize', 'recommended_size', 'clothing_size'], 'Medium (M)'),
      sizeMatchScore: _parseInt(json['sizeMatchScore'] ?? json['size_match_score'], 85),
      colorMatchScore: _parseInt(json['colorMatchScore'] ?? json['color_match_score'], 88),
      qualityScore: _parseInt(json['qualityScore'] ?? json['quality_score'], 80),
      clothingTexture: _parseString(json, ['clothingTexture', 'clothing_texture', 'fabric', 'texture'], 'Standard Fabric'),
      clothingQuality: _parseString(json, ['clothingQuality', 'clothing_quality', 'quality'], 'Good Quality'),
      buyAdvice: _parseString(json, ['buyAdvice', 'buy_advice', 'recommendation', 'verdict'], 'Recommended'),
      reasoning: _parseString(json, ['reasoning', 'advice', 'explanation', 'description'], 'The item fits your proportions and complements your skin tone well.'),
    );
  }

  FitLensResultEntity toEntity() {
    return FitLensResultEntity(
      skinTone: skinTone,
      estimatedSize: estimatedSize,
      recommendedSize: recommendedSize,
      sizeMatchScore: sizeMatchScore,
      colorMatchScore: colorMatchScore,
      qualityScore: qualityScore,
      clothingTexture: clothingTexture,
      clothingQuality: clothingQuality,
      buyAdvice: buyAdvice,
      reasoning: reasoning,
    );
  }
}
