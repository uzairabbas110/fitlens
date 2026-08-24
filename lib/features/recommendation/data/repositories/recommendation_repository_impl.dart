import 'dart:typed_data';

import '../../../analysis/domain/entities/analysis_entity.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_data_source.dart';

/// Concrete implementation of [RecommendationRepository].
///
/// Delegates the actual recommendation work to
/// [RecommendationRemoteDataSource] and converts the resulting
/// [RecommendationModel] into a domain [RecommendationEntity]. Contains
/// no business logic of its own — its only responsibility is bridging
/// the data layer to the domain layer.
class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;

  const RecommendationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RecommendationEntity> generateRecommendation({
    required Uint8List imageBytes,
    required AnalysisEntity analysis,
  }) async {
    try {
      final model = await remoteDataSource.generateRecommendation(
        imageBytes: imageBytes,
        analysis: analysis,
      );
      return model.toEntity();
    } catch (e, stackTrace) {
      throw RecommendationRepositoryException(
        'Failed to generate outfit recommendation: $e',
        stackTrace,
      );
    }
  }
}

/// Thrown when [RecommendationRepositoryImpl] fails to obtain or convert
/// a recommendation result, preserving the original cause and stack
/// trace for diagnostic purposes.
class RecommendationRepositoryException implements Exception {
  final String message;
  final StackTrace stackTrace;

  const RecommendationRepositoryException(this.message, this.stackTrace);

  @override
  String toString() => 'RecommendationRepositoryException: $message';
}