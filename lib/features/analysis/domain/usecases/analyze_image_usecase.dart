import 'dart:typed_data';

import '../entities/analysis_entity.dart';
import '../repositories/analysis_repository.dart';

/// Use case for analyzing a clothing image.
///
/// This class represents a single business operation in the Domain layer.
/// It delegates the analysis process to the [AnalysisRepository], keeping
/// the Presentation layer independent from the Data layer.
///
/// Following Clean Architecture, this use case contains no knowledge of
/// AI models, APIs, Firebase, or other implementation details.
class AnalyzeImageUseCase {
  /// Repository used to perform image analysis.
  final AnalysisRepository repository;

  /// Creates a new instance of [AnalyzeImageUseCase].
  const AnalyzeImageUseCase(this.repository);

  /// Analyzes the image located at the given local [imagePath].
  ///
  /// Returns an [AnalysisEntity] containing:
  /// - clothing type
  /// - color
  /// - pattern
  /// - material
  /// - recommended season
  /// - suitable occasion
  /// - confidence score
  Future<AnalysisEntity> call(Uint8List imageBytes) {
    return repository.analyzeImage(imageBytes);
  }
}