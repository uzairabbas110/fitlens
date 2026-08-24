/// Generates unique identifiers for new history records.
///
/// The domain layer depends only on this abstraction and never imports
/// Firestore directly.
abstract class HistoryIdGenerator {
  const HistoryIdGenerator();

  /// Returns a unique history record id.
  String generateId();
}