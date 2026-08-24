import 'dart:typed_data';
import '../entities/color_recommendation_entity.dart';

abstract class ColorAnalysisRepository {
  Future<ColorRecommendationEntity> analyzeSkinTone(Uint8List imageBytes);
  Future<ColorRecommendationEntity?> getSavedColorAnalysis(String userId);
  Future<void> saveColorAnalysis(String userId, ColorRecommendationEntity entity);
}
