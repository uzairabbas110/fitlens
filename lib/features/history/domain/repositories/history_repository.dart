import '../entities/history_entity.dart';

/// Defines the contract for persisting and retrieving clothing analysis
/// and outfit recommendation history.
///
/// This repository belongs to the domain layer, describing *what* the
/// application can do without knowing or caring *how* it is done.
/// Concrete implementations (for example, a Firestore-backed repository)
/// live in the data layer and depend on this contract, keeping the
/// domain layer independent of frameworks and third-party packages.
abstract class HistoryRepository {
  /// Saves a new [history] record for the currently authenticated user.
  ///
  /// If persistence fails, the implementation should throw an exception.
  Future<void> saveHistory(HistoryEntity history);

  /// Retrieves all saved history records belonging to the currently
  /// authenticated user.
  ///
  /// Returns an empty list if no history records exist.
  Future<List<HistoryEntity>> getHistory();

  /// Deletes the history record identified by [historyId].
  ///
  /// If the record does not exist, the implementation may silently
  /// succeed or throw an implementation-specific exception.
  Future<void> deleteHistory(String historyId);

  /// Deletes every history record belonging to the currently
  /// authenticated user.
  Future<void> clearHistory();
}