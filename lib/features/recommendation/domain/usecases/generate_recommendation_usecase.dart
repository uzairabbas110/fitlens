import 'dart:typed_data';

import '../../../analysis/domain/entities/analysis_entity.dart';
import '../entities/recommendation_entity.dart';
import '../repositories/recommendation_repository.dart';

/// Encapsulates the single action of generating an outfit recommendation
/// from a previously analyzed clothing image.
///
/// Delegates the actual work to [RecommendationRepository], keeping this
/// use case a thin, single-responsibility entry point that the
/// presentation layer can depend on without knowing about the underlying
/// repository implementation.
class GenerateRecommendationUseCase {
  final RecommendationRepository repository;

  const GenerateRecommendationUseCase(this.repository);

  /// Generates an outfit recommendation for the clothing item at
  /// [imageBytes], using the previously computed [analysis] result.
  ///
  /// Returns a [RecommendationEntity] containing the recommended top,
  /// bottom, footwear, accessory, style description, color harmony,
  /// reasoning, and confidence score.
  Future<RecommendationEntity> call({
    required Uint8List imageBytes,
    required AnalysisEntity analysis,
  }) {
    return repository.generateRecommendation(
      imageBytes: imageBytes,
      analysis: analysis,
    );
  }
}