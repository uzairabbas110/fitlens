import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/services/history_id_generator.dart';

/// Firestore implementation of [HistoryIdGenerator].
///
/// Uses Firestore's client-side document id generation to create
/// unique history ids without writing any data.
class FirestoreHistoryIdGenerator implements HistoryIdGenerator {
  final FirebaseFirestore firestore;

  const FirestoreHistoryIdGenerator({
    required this.firestore,
  });

  @override
  String generateId() {
    return firestore.collection('history').doc().id;
  }
}