
import '../../domain/entities/selected_image_entity.dart';
import '../../domain/repositories/image_picker_repository.dart';
import '../datasources/image_picker_datasource.dart';

class ImagePickerRepositoryImpl implements ImagePickerRepository {
  final ImagePickerDataSource _dataSource;

  const ImagePickerRepositoryImpl({
    required this._dataSource,
  });

  @override
  Future<SelectedImageEntity?> pickImage(ImagePickSource source) async {
    final pickedFile = await _dataSource.pickImage(source);

    if (pickedFile == null) return null;

    return SelectedImageEntity(
      bytes: await pickedFile.readAsBytes(),
      fileName: pickedFile.name,
    );
  }
}