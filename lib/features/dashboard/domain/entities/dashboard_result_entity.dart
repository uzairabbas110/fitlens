class FitLensResultEntity {
  final String skinTone;
  final String estimatedSize;
  final String recommendedSize;
  final int sizeMatchScore;
  final int colorMatchScore;
  final int qualityScore;
  final String clothingTexture;
  final String clothingQuality;
  final String buyAdvice;
  final String reasoning;

  const FitLensResultEntity({
    required this.skinTone,
    required this.estimatedSize,
    required this.recommendedSize,
    required this.sizeMatchScore,
    required this.colorMatchScore,
    required this.qualityScore,
    required this.clothingTexture,
    required this.clothingQuality,
    required this.buyAdvice,
    required this.reasoning,
  });
}
