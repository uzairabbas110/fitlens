import 'dart:typed_data';
import '../../domain/entities/closet_item_entity.dart';
import '../../domain/repositories/closet_repository.dart';
import '../datasources/closet_remote_data_source.dart';
import '../models/closet_model.dart';

class ClosetRepositoryImpl implements ClosetRepository {
  final ClosetRemoteDataSource remoteDataSource;

  ClosetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ClosetItemEntity>> getClosetItems(String userId) async {
    return await remoteDataSource.getClosetItems(userId);
  }

  @override
  Future<void> addClosetItem(ClosetItemEntity item) async {
    final model = ClosetModel.fromEntity(item);
    await remoteDataSource.addClosetItem(model);
  }

  @override
  Future<void> deleteClosetItem(String itemId) async {
    await remoteDataSource.deleteClosetItem(itemId);
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    return await remoteDataSource.uploadImage(imageBytes, fileName);
  }
}
