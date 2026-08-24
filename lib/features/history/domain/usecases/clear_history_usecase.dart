import '../repositories/history_repository.dart';

/// Encapsulates the single action of clearing all history records.
///
/// Delegates the actual work to [HistoryRepository], keeping this use
/// case a thin, single-responsibility entry point that the presentation
/// layer can depend on without knowing about the underlying repository
/// implementation.
class ClearHistoryUseCase {
  final HistoryRepository repository;

  const ClearHistoryUseCase(this.repository);

  /// Clears all history records.
  Future<void> call() {
    return repository.clearHistory();
  }
}