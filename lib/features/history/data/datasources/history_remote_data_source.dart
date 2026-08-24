import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/history_model.dart';

/// Thrown when a history operation is attempted without an authenticated
/// user present.
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Thrown when a Firestore operation fails while reading, writing,
/// deleting, or clearing history records.
class HistoryRemoteDataSourceException implements Exception {
  final String message;

  const HistoryRemoteDataSourceException(this.message);

  @override
  String toString() => 'HistoryRemoteDataSourceException: $message';
}

/// Defines the contract for persisting and retrieving history records
/// from a remote source.
///
/// This is a data-layer abstraction only — it describes *what* the
/// remote data source can do, not which backend it uses under the hood.
abstract class HistoryRemoteDataSource {
  /// Saves [history] for the currently authenticated user.
  Future<void> saveHistory(HistoryModel history);

  /// Retrieves all history records for the currently authenticated user.
  Future<List<HistoryModel>> getHistory();

  /// Deletes the history record identified by [historyId].
  Future<void> deleteHistory(String historyId);

  /// Deletes all history records for the currently authenticated user.
  Future<void> clearHistory();
}

/// Concrete implementation of [HistoryRemoteDataSource] backed by Cloud
/// Firestore, storing each user's history under:
/// `users/{uid}/history/{historyId}`.
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const HistoryRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  /// Returns the currently authenticated user's UID, or throws an
  /// [AuthenticationException] if no user is signed in.
  String _requireUserId() {
    final user = auth.currentUser;
    if (user == null) {
      throw const AuthenticationException(
        'No authenticated user found. History operations require sign-in.',
      );
    }
    return user.uid;
  }

  /// Returns the Firestore collection reference for the authenticated
  /// user's history documents.
  CollectionReference<Map<String, dynamic>> _historyCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('history');
  }

  @override
  Future<void> saveHistory(HistoryModel history) async {
    final uid = _requireUserId();

    try {
      await _historyCollection(uid).doc(history.id).set(history.toJson());
    } on FirebaseException catch (e) {
      throw HistoryRemoteDataSourceException(
        'Failed to save history record: ${e.message}',
      );
    }
  }

  @override
  Future<List<HistoryModel>> getHistory() async {
    final uid = _requireUserId();

    try {
      final snapshot = await _historyCollection(uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HistoryModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw HistoryRemoteDataSourceException(
        'Failed to retrieve history records: ${e.message}',
      );
    }
  }

  @override
  Future<void> deleteHistory(String historyId) async {
    final uid = _requireUserId();

    try {
      await _historyCollection(uid).doc(historyId).delete();
    } on FirebaseException catch (e) {
      throw HistoryRemoteDataSourceException(
        'Failed to delete history record: ${e.message}',
      );
    }
  }

  @override
  Future<void> clearHistory() async {
    final uid = _requireUserId();

    try {
      final snapshot = await _historyCollection(uid).get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw HistoryRemoteDataSourceException(
        'Failed to clear history records: ${e.message}',
      );
    }
  }
}