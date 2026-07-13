

import '../../domain/entities/selected_image_entity.dart';
import '../../domain/repositories/image_picker_repository.dart';
import '../datasources/image_picker_datasource.dart';

// Concrete implementation of ImagePickerRepository.
class ImagePickerRepositoryImpl implements ImagePickerRepository {
  final ImagePickerDataSource _dataSource;

  ImagePickerRepositoryImpl({
    required ImagePickerDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<SelectedImageEntity?> pickImage(ImagePickSource source) async {
    final pickedFile = await _dataSource.pickImage(source);

    if (pickedFile == null) return null;

    final bytes = await pickedFile.readAsBytes();

    return SelectedImageEntity(
      bytes: bytes,
      fileName: pickedFile.name,
    );
  }
}