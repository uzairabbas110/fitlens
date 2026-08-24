import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/datasources/history_remote_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/save_history_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/delete_history_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';

import '../../../dashboard/domain/entities/dashboard_result_entity.dart';

import '../../data/services/firebase_current_user_id_provider.dart';
import '../../data/services/firestore_history_id_generator.dart';

import '../../domain/services/current_user_id_provider.dart';
import '../../domain/services/history_id_generator.dart';

import '../../domain/usecases/save_recommendation_history_usecase.dart';

// ============================================================
// DEPENDENCY WIRING
// firestore/auth -> remoteDataSource -> repository -> usecases -> notifier
// ============================================================

/// Provides the Firestore instance used for persisting history records.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the FirebaseAuth instance used to identify the currently
/// authenticated user.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides the remote data source responsible for reading and writing
/// history records in Firestore.
final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

/// Provides the repository that bridges the remote data source to the
/// domain layer.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    remoteDataSource: ref.watch(historyRemoteDataSourceProvider),
  );
});

/// Provides the current authenticated user's id.
final currentUserIdProvider = Provider<CurrentUserIdProvider>((ref) {
  return FirebaseCurrentUserIdProvider(
    auth: ref.watch(firebaseAuthProvider),
  );
});

/// Provides unique ids for history records.
final historyIdGeneratorProvider = Provider<HistoryIdGenerator>((ref) {
  return FirestoreHistoryIdGenerator(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

/// Provides the use case that converts a recommendation into
/// a history record and saves it.
final saveRecommendationHistoryUseCaseProvider =
Provider<SaveRecommendationHistoryUseCase>((ref) {
  return SaveRecommendationHistoryUseCase(
    repository: ref.watch(historyRepositoryProvider),
    currentUserIdProvider: ref.watch(currentUserIdProvider),
    historyIdGenerator: ref.watch(historyIdGeneratorProvider),
  );
});

/// Provides the single-purpose use case for saving a history record.
final saveHistoryUseCaseProvider = Provider<SaveHistoryUseCase>((ref) {
  return SaveHistoryUseCase(ref.watch(historyRepositoryProvider));
});

/// Provides the single-purpose use case for retrieving history records.
final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  return GetHistoryUseCase(ref.watch(historyRepositoryProvider));
});

/// Provides the single-purpose use case for deleting a history record.
final deleteHistoryUseCaseProvider = Provider<DeleteHistoryUseCase>((ref) {
  return DeleteHistoryUseCase(ref.watch(historyRepositoryProvider));
});

/// Provides the single-purpose use case for clearing all history records.
final clearHistoryUseCaseProvider = Provider<ClearHistoryUseCase>((ref) {
  return ClearHistoryUseCase(ref.watch(historyRepositoryProvider));
});

// ============================================================
// NOTIFIER (Riverpod 3.x — AsyncNotifier for async-driven state)
// ============================================================

/// Manages the list of history records for the currently authenticated
/// user.
///
/// Uses [AsyncNotifier] so loading, data, and error states are
/// represented automatically via [AsyncValue] rather than being tracked
/// manually. Never manipulates Firestore directly — only calls use
/// cases, keeping this notifier a thin coordination layer.
class HistoryNotifier extends AsyncNotifier<List<HistoryEntity>> {
  // Riverpod 3 calls this once to produce the initial state, which
  // automatically loads all existing history records.
  @override
  Future<List<HistoryEntity>> build() async {
    final getHistory = ref.read(getHistoryUseCaseProvider);
    return getHistory();
  }

  /// Reloads history records from Firestore and updates state.
  Future<void> refreshHistory() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final getHistory = ref.read(getHistoryUseCaseProvider);
      return getHistory();
    });
  }

  /// Saves [history] as a new record, then refreshes the history list.
  Future<void> saveHistory(HistoryEntity history) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final saveHistory = ref.read(saveHistoryUseCaseProvider);
      await saveHistory(history);

      final getHistory = ref.read(getHistoryUseCaseProvider);
      return getHistory();
    });
  }

  /// Deletes the history record identified by [historyId], then
  /// refreshes the history list.
  Future<void> deleteHistory(String historyId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final deleteHistory = ref.read(deleteHistoryUseCaseProvider);
      await deleteHistory(historyId);

      final getHistory = ref.read(getHistoryUseCaseProvider);
      return getHistory();
    });
  }

  /// Clears all history records, then refreshes the history list.
  Future<void> clearHistory() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final clearHistory = ref.read(clearHistoryUseCaseProvider);
      await clearHistory();

      final getHistory = ref.read(getHistoryUseCaseProvider);
      return getHistory();
    });
  }
  /// Saves a completed analysis result into history.
  Future<void> saveDashboardResult({
    required FitLensResultEntity result,
    required String feature,
    String? userImagePath,
    String? clothingImagePath,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final saveRecommendation =
      ref.read(saveRecommendationHistoryUseCaseProvider);

      await saveRecommendation(
        result: result,
        feature: feature,
        userImagePath: userImagePath,
        clothingImagePath: clothingImagePath,
      );

      final getHistory = ref.read(getHistoryUseCaseProvider);
      return getHistory();
    });

    if (state.hasError) {
      developer.log(
        'Failed to save result to history.',
        error: state.error,
        stackTrace: state.stackTrace,
      );
    }
  }
}

/// Exposes [HistoryNotifier] and its current
/// [AsyncValue<List<HistoryEntity>>] state to the presentation layer.
final historyNotifierProvider =
AsyncNotifierProvider<HistoryNotifier, List<HistoryEntity>>(
  HistoryNotifier.new,
);