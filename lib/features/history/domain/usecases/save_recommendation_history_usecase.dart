import '../../../dashboard/domain/entities/dashboard_result_entity.dart';

import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';
import '../services/current_user_id_provider.dart';
import '../services/history_id_generator.dart';

/// Thrown when attempting to save history without an authenticated user.
class NoAuthenticatedUserException implements Exception {
  final String message;

  const NoAuthenticatedUserException(this.message);

  @override
  String toString() => 'NoAuthenticatedUserException: $message';
}

/// Creates a complete [HistoryEntity] from a [FitLensResultEntity],
/// then persists it.
class SaveRecommendationHistoryUseCase {
  final HistoryRepository repository;
  final CurrentUserIdProvider currentUserIdProvider;
  final HistoryIdGenerator historyIdGenerator;

  const SaveRecommendationHistoryUseCase({
    required this.repository,
    required this.currentUserIdProvider,
    required this.historyIdGenerator,
  });

  Future<void> call({
    required FitLensResultEntity result,
    required String feature,
    String? userImagePath,
    String? clothingImagePath,
  }) async {
    final userId = currentUserIdProvider.getCurrentUserId();

    if (userId == null) {
      throw const NoAuthenticatedUserException(
        'No authenticated user found.',
      );
    }

    final history = HistoryEntity(
      id: historyIdGenerator.generateId(),
      userId: userId,
      feature: feature,
      userImagePath: userImagePath,
      clothingImagePath: clothingImagePath,
      skinTone: result.skinTone,
      estimatedSize: result.estimatedSize,
      recommendedSize: result.recommendedSize,
      sizeMatchScore: result.sizeMatchScore,
      colorMatchScore: result.colorMatchScore,
      clothingTexture: result.clothingTexture,
      clothingQuality: result.clothingQuality,
      qualityScore: result.qualityScore,
      buyAdvice: result.buyAdvice,
      reasoning: result.reasoning,
      createdAt: DateTime.now(),
    );

    await repository.saveHistory(history);
  }
}