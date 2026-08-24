import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/cloudflare_storage_service.dart';
import '../models/closet_model.dart';

abstract class ClosetRemoteDataSource {
  Future<List<ClosetModel>> getClosetItems(String userId);
  Future<void> addClosetItem(ClosetModel item);
  Future<void> deleteClosetItem(String itemId);
  Future<String> uploadImage(Uint8List imageBytes, String fileName);
}

class ClosetRemoteDataSourceImpl implements ClosetRemoteDataSource {
  final FirebaseFirestore firestore;

  ClosetRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<List<ClosetModel>> getClosetItems(String userId) async {
    try {
      final snapshot = await firestore
          .collection('closet_items')
          .where('userId', isEqualTo: userId)
          .get();

      final items = snapshot.docs
          .map((doc) => ClosetModel.fromJson(doc.data()..addAll({'id': doc.id})))
          .toList();
          
      // Sort in Dart to avoid needing a Firestore composite index
      items.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      return items;
    } catch (e) {
      throw Exception('Failed to get closet items: $e');
    }
  }

  @override
  Future<void> addClosetItem(ClosetModel item) async {
    try {
      final docRef = firestore.collection('closet_items').doc(item.id.isEmpty ? null : item.id);
      
      final newItem = ClosetModel(
        id: docRef.id,
        userId: item.userId,
        imageUrl: item.imageUrl,
        category: item.category,
        color: item.color,
        season: item.season,
        dateAdded: item.dateAdded,
      );

      await docRef.set(newItem.toJson());
    } catch (e) {
      throw Exception('Failed to add closet item: $e');
    }
  }

  @override
  Future<void> deleteClosetItem(String itemId) async {
    try {
      await firestore.collection('closet_items').doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete closet item: $e');
    }
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      return await CloudflareStorageService.uploadImage(imageBytes, fileName);
    } catch (e) {
      throw Exception('Failed to upload image to Cloudflare Storage: $e');
    }
  }
}
