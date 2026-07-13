import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/image_picker_repository.dart';

// Wraps the ImagePicker plugin.
class ImagePickerDataSource {
  final ImagePicker _picker;

  ImagePickerDataSource({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  Future<XFile?> pickImage(ImagePickSource source) {
    return _picker.pickImage(
      source: source == ImagePickSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
  }
}