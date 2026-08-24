import 'dart:typed_data';

import '../../domain/entities/analysis_entity.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_remote_data_source.dart';

/// Concrete implementation of [AnalysisRepository].
///
/// Delegates the actual analysis work to [AnalysisRemoteDataSource] and
/// converts the resulting [AnalysisModel] into a domain [AnalysisEntity].
/// Contains no business logic of its own — its only responsibility is
/// bridging the data layer to the domain layer.
class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisRemoteDataSource remoteDataSource;

  const AnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AnalysisEntity> analyzeImage(Uint8List imageBytes) async {
    try {
      final model = await remoteDataSource.analyzeImage(imageBytes);
      return model.toEntity();
    } catch (e, stackTrace) {
      throw AnalysisRepositoryException(
        'Failed to analyze clothing image: $e',
        stackTrace,
      );
    }
  }
}

/// Thrown when [AnalysisRepositoryImpl] fails to obtain or convert an
/// analysis result, preserving the original cause and stack trace for
/// diagnostic purposes.
class AnalysisRepositoryException implements Exception {
  final String message;
  final StackTrace stackTrace;

  const AnalysisRepositoryException(this.message, this.stackTrace);

  @override
  String toString() => 'AnalysisRepositoryException: $message';
}
