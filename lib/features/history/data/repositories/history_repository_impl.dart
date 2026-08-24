import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';
import '../models/history_model.dart';

/// Concrete implementation of [HistoryRepository].
///
/// Delegates the actual persistence work to [HistoryRemoteDataSource],
/// converting between [HistoryEntity] (domain) and [HistoryModel] (data)
/// at the boundary. Contains no business logic of its own — its only
/// responsibility is bridging the data layer to the domain layer.
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  const HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveHistory(HistoryEntity history) async {
    try {
      final model = HistoryModel.fromEntity(history);
      await remoteDataSource.saveHistory(model);
    } catch (e, stackTrace) {
      throw HistoryRepositoryException(
        'Failed to save history record: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<List<HistoryEntity>> getHistory() async {
    try {
      final models = await remoteDataSource.getHistory();
      return models.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      throw HistoryRepositoryException(
        'Failed to retrieve history records: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteHistory(String historyId) async {
    try {
      await remoteDataSource.deleteHistory(historyId);
    } catch (e, stackTrace) {
      throw HistoryRepositoryException(
        'Failed to delete history record: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await remoteDataSource.clearHistory();
    } catch (e, stackTrace) {
      throw HistoryRepositoryException(
        'Failed to clear history records: $e',
        stackTrace,
      );
    }
  }
}

/// Thrown when [HistoryRepositoryImpl] fails to complete a history
/// operation, preserving the original cause and stack trace for
/// diagnostic purposes.
class HistoryRepositoryException implements Exception {
  final String message;
  final StackTrace stackTrace;

  const HistoryRepositoryException(this.message, this.stackTrace);

  @override
  String toString() => 'HistoryRepositoryException: $message';
}