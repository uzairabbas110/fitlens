import '../entities/selected_image_entity.dart';

// Where the image comes from
enum ImagePickSource { camera, gallery }

// Abstract contract. The presentation layer depends on this,
// never on the concrete ImagePicker implementation.
abstract class ImagePickerRepository {
  /// Opens the camera or gallery and returns the picked image,
  /// or null if the user cancelled.
  Future<SelectedImageEntity?> pickImage(ImagePickSource source);
}