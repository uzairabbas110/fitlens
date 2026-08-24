import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/color_recommendation_entity.dart';
import '../../domain/repositories/color_analysis_repository.dart';
import '../datasources/color_analysis_remote_data_source.dart';
import '../models/color_recommendation_model.dart';

class ColorAnalysisRepositoryImpl implements ColorAnalysisRepository {
  final ColorAnalysisRemoteDataSource remoteDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ColorAnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ColorRecommendationEntity> analyzeSkinTone(Uint8List imageBytes) async {
    return await remoteDataSource.analyzeSkinTone(imageBytes);
  }

  @override
  Future<ColorRecommendationEntity?> getSavedColorAnalysis(String userId) async {
    try {
      final doc = await _firestore.collection('color_analysis').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return ColorRecommendationModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting saved color analysis: $e');
      return null;
    }
  }

  @override
  Future<void> saveColorAnalysis(String userId, ColorRecommendationEntity entity) async {
    try {
      final model = ColorRecommendationModel(
        skinTone: entity.skinTone,
        description: entity.description,
        recommendedColors: entity.recommendedColors,
      );
      await _firestore.collection('color_analysis').doc(userId).set(model.toJson());
    } catch (e) {
      debugPrint('Error saving color analysis: $e');
    }
  }
}
