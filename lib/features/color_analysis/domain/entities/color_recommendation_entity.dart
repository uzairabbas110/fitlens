class ColorRecommendationEntity {
  final String skinTone;
  final String description;
  final List<String> recommendedColors;

  const ColorRecommendationEntity({
    required this.skinTone,
    required this.description,
    required this.recommendedColors,
  });
}
