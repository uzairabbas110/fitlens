import 'dart:typed_data';
import '../entities/closet_item_entity.dart';

abstract class ClosetRepository {
  Future<List<ClosetItemEntity>> getClosetItems(String userId);
  Future<void> addClosetItem(ClosetItemEntity item);
  Future<void> deleteClosetItem(String itemId);
  Future<String> uploadImage(Uint8List imageBytes, String fileName);
}
