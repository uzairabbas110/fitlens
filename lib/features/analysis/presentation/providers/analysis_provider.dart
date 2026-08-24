import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/analysis_remote_data_source.dart';
import '../../data/repositories/analysis_repository_impl.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../../domain/usecases/analyze_image_usecase.dart';

/// =============================================================
/// Dependency Injection
/// =============================================================

/// Provides the remote data source responsible for communicating
/// with Gemini Vision.
final analysisRemoteDataSourceProvider =
Provider<AnalysisRemoteDataSource>((ref) {
  return const AnalysisRemoteDataSourceImpl();
});

/// Provides the repository implementation.
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return AnalysisRepositoryImpl(
    remoteDataSource: ref.watch(analysisRemoteDataSourceProvider),
  );
});

/// Provides the image analysis use case.
final analyzeImageUseCaseProvider = Provider<AnalyzeImageUseCase>((ref) {
  return AnalyzeImageUseCase(
    ref.watch(analysisRepositoryProvider),
  );
});

/// =============================================================
/// Analysis State Management
/// =============================================================

/// Handles clothing image analysis and exposes the current state
/// as an [AsyncValue].
class AnalysisNotifier extends AsyncNotifier<AnalysisEntity?> {
  @override
  Future<AnalysisEntity?> build() async {
    return null;
  }

  /// Sends the image to Gemini for analysis and updates the state.
  Future<void> analyzeImage(Uint8List imageBytes) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(analyzeImageUseCaseProvider);
      return await useCase(imageBytes);
    });
  }

  /// Clears the current analysis result.
  void clear() {
    state = const AsyncData(null);
  }
}

/// Provider exposing the analysis state.
final analysisNotifierProvider =
AsyncNotifierProvider<AnalysisNotifier, AnalysisEntity?>(
  AnalysisNotifier.new,
);