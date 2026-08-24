import '../repositories/history_repository.dart';

/// Encapsulates the single action of deleting a history record.
///
/// Delegates the actual work to [HistoryRepository], keeping this use
/// case a thin, single-responsibility entry point that the presentation
/// layer can depend on without knowing about the underlying repository
/// implementation.
class DeleteHistoryUseCase {
  final HistoryRepository repository;

  const DeleteHistoryUseCase(this.repository);

  /// Deletes the history record identified by [historyId].
  Future<void> call(String historyId) {
    return repository.deleteHistory(historyId);
  }
}