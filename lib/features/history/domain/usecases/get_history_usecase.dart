import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

/// Encapsulates the single action of retrieving all history records.
///
/// Delegates the actual work to [HistoryRepository], keeping this use
/// case a thin, single-responsibility entry point that the presentation
/// layer can depend on without knowing about the underlying repository
/// implementation.
class GetHistoryUseCase {
  final HistoryRepository repository;

  const GetHistoryUseCase(this.repository);

  /// Retrieves all history records.
  Future<List<HistoryEntity>> call() {
    return repository.getHistory();
  }
}