import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../analysis/domain/entities/analysis_entity.dart';
import '../../data/datasources/recommendation_remote_data_source.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/usecases/generate_recommendation_usecase.dart';

// ============================================================
// DEPENDENCY WIRING
// remoteDataSource -> repository -> usecase -> notifier
// ============================================================

/// Provides the remote data source responsible for sending the image and
/// analysis result to Gemini and parsing the resulting recommendation.
final recommendationRemoteDataSourceProvider =
Provider<RecommendationRemoteDataSource>((ref) {
  return const RecommendationRemoteDataSourceImpl();
});

/// Provides the repository that bridges the remote data source to the
/// domain layer.
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepositoryImpl(
    remoteDataSource: ref.watch(recommendationRemoteDataSourceProvider),
  );
});

/// Provides the single-purpose use case for generating an outfit
/// recommendation.
final generateRecommendationUseCaseProvider =
Provider<GenerateRecommendationUseCase>((ref) {
  return GenerateRecommendationUseCase(ref.watch(recommendationRepositoryProvider));
});

// ============================================================
// NOTIFIER (Riverpod 3.x — AsyncNotifier for async-driven state)
// ============================================================

/// Manages the state of an outfit recommendation operation.
///
/// Uses [AsyncNotifier] so loading, data, and error states are
/// represented automatically via [AsyncValue] rather than being tracked
/// manually. Holds no UI, navigation, or image-picking logic — its sole
/// responsibility is coordinating the recommendation use case and
/// exposing its result.
class RecommendationNotifier extends AsyncNotifier<RecommendationEntity?> {
  // Riverpod 3 calls this once to produce the initial state.
  // No recommendation has been generated yet, so we start with no data.
  @override
  Future<RecommendationEntity?> build() async {
    return null;
  }

  /// Generates an outfit recommendation for the clothing item at
  /// [imagePath], using the previously computed [analysis] result.
  ///
  /// While running, state becomes [AsyncLoading]. On success, state
  /// becomes [AsyncData] holding the resulting [RecommendationEntity]. On
  /// failure, state becomes [AsyncError] holding the thrown error and
  /// stack trace.
  Future<void> generateRecommendation({
    required Uint8List imageBytes,
    required AnalysisEntity analysis,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final generateRecommendationUseCase =
      ref.read(generateRecommendationUseCaseProvider);
      return generateRecommendationUseCase(
        imageBytes: imageBytes,
        analysis: analysis,
      );
    });
  }
}

/// Exposes [RecommendationNotifier] and its current
/// [AsyncValue<RecommendationEntity?>] state to the presentation layer.
final recommendationNotifierProvider =
AsyncNotifierProvider<RecommendationNotifier, RecommendationEntity?>(
  RecommendationNotifier.new,
);