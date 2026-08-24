class MeasurementEntity {
  final String estimatedSize;
  final String bodyType;
  final List<String> brandRecommendations;
  final String advice;
  final String? imageUrl;
  final double? chestInches;
  final double? waistInches;
  final double? hipsInches;

  MeasurementEntity({
    required this.estimatedSize,
    required this.bodyType,
    required this.brandRecommendations,
    required this.advice,
    this.imageUrl,
    this.chestInches,
    this.waistInches,
    this.hipsInches,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  factory MeasurementEntity.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      } else if (val is String && val.isNotEmpty) {
        return val.split(RegExp(r'[,;\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return MeasurementEntity(
      estimatedSize: (json['estimated_size'] ?? json['estimatedSize'] ?? json['size'] ?? 'Medium (M)').toString(),
      bodyType: (json['body_type'] ?? json['bodyType'] ?? json['type'] ?? 'Proportional').toString(),
      brandRecommendations: parseList(json['brand_recommendations'] ?? json['brandRecommendations']),
      advice: (json['advice'] ?? json['style_advice'] ?? json['recommendation'] ?? 'Tailored and well-fitted pieces will highlight your natural silhouette.').toString(),
      imageUrl: json['image_url'] as String?,
      chestInches: _parseDouble(json['chest_inches'] ?? json['chestInches'] ?? json['chest']),
      waistInches: _parseDouble(json['waist_inches'] ?? json['waistInches'] ?? json['waist']),
      hipsInches: _parseDouble(json['hips_inches'] ?? json['hipsInches'] ?? json['hips']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimated_size': estimatedSize,
      'body_type': bodyType,
      'brand_recommendations': brandRecommendations,
      'advice': advice,
      'image_url': imageUrl,
      'chest_inches': chestInches,
      'waist_inches': waistInches,
      'hips_inches': hipsInches,
    };
  }
}

