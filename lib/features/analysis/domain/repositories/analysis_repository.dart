import 'dart:typed_data';

import '../entities/analysis_entity.dart';

/// Contract for the Analysis feature.
///
/// This repository defines the operations available for analyzing
/// a clothing image. It belongs to the Domain layer and specifies
/// *what* the application can do without defining *how* it is done.
///
/// The concrete implementation will be provided in the Data layer,
/// which may use AI services, machine learning models, APIs, or
/// other technologies. The Domain layer remains completely
/// independent of those implementation details.
abstract class AnalysisRepository {
  /// Analyzes the image located at the given local [imagePath].
  ///
  /// The [imagePath] should point to an image stored on the user's
  /// device.
  ///
  /// Returns an [AnalysisEntity] containing:
  /// - clothing type
  /// - color
  /// - pattern
  /// - material
  /// - recommended season
  /// - suitable occasion
  /// - confidence score
  ///
  /// Throws an exception if the analysis cannot be completed.
  Future<AnalysisEntity> analyzeImage(Uint8List imageBytes);
}