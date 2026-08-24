import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/services/history_id_generator.dart';

class FirestoreHistoryIdGenerator extends HistoryIdGenerator {
  final FirebaseFirestore firestore;

  const FirestoreHistoryIdGenerator({required this.firestore});

  @override
  String generateId() {
    return firestore.collection('history').doc().id;
  }
}
