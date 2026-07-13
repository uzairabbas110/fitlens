import '../entities/selected_image_entity.dart';
import '../repositories/image_picker_repository.dart';

// Encapsulates the single action of picking an image.
class PickImageUseCase {
  final ImagePickerRepository _repository;

  PickImageUseCase(this._repository);

  Future<SelectedImageEntity?> call(ImagePickSource source) {
    return _repository.pickImage(source);
  }
}