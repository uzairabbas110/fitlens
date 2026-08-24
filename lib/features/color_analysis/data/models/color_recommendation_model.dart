import '../../domain/entities/color_recommendation_entity.dart';

class ColorRecommendationModel extends ColorRecommendationEntity {
  const ColorRecommendationModel({
    required super.skinTone,
    required super.description,
    required super.recommendedColors,
  });

  factory ColorRecommendationModel.fromJson(Map<String, dynamic> json) {
    return ColorRecommendationModel(
      skinTone: json['skinTone'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? 'No description provided.',
      recommendedColors: (json['recommendedColors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skinTone': skinTone,
      'description': description,
      'recommendedColors': recommendedColors,
    };
  }
}
