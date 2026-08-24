import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

/// Encapsulates the single action of saving a history record.
///
/// Delegates the actual work to [HistoryRepository], keeping this use
/// case a thin, single-responsibility entry point that the presentation
/// layer can depend on without knowing about the underlying repository
/// implementation.
class SaveHistoryUseCase {
  final HistoryRepository repository;

  const SaveHistoryUseCase(this.repository);

  /// Saves [history] as a new record.
  Future<void> call(HistoryEntity history) {
    return repository.saveHistory(history);
  }
}