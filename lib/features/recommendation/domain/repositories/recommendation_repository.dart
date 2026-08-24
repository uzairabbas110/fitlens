import 'dart:typed_data';

import '../../../analysis/domain/entities/analysis_entity.dart';
import '../entities/recommendation_entity.dart';

/// Defines the contract for generating a clothing recommendation based
/// on a previously analyzed image.
///
/// This repository belongs to the domain layer, describing *what* the
/// application can do without knowing or caring *how* it is done. The
/// concrete implementation lives in the data layer and depends on this
/// contract, keeping the domain layer independent of any framework or
/// third-party package.
abstract class RecommendationRepository {
  /// Generates an outfit recommendation for the clothing item at
  /// [imagePath], using the previously computed [analysis] result.
  ///
  /// Returns a [RecommendationEntity] containing the recommended top,
  /// bottom, footwear, accessory, style description, color harmony,
  /// reasoning, and confidence score.
  Future<RecommendationEntity> generateRecommendation({
    required Uint8List imageBytes,
    required AnalysisEntity analysis,
  });
}