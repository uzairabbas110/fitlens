import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/image_picker_datasource.dart';
import '../../data/repositories/image_picker_repository_impl.dart';
import '../../domain/entities/selected_image_entity.dart';
import '../../domain/repositories/image_picker_repository.dart';
import '../../domain/usecases/pick_image_usecase.dart';


// ================================
// Dependency Injection
// datasource → repository → usecase
// ================================

final imagePickerDataSourceProvider =
Provider<ImagePickerDataSource>((ref) {
  return ImagePickerDataSource();
});


final imagePickerRepositoryProvider =
Provider<ImagePickerRepository>((ref) {
  return ImagePickerRepositoryImpl(
    dataSource: ref.watch(imagePickerDataSourceProvider),
  );
});


final pickImageUseCaseProvider =
Provider<PickImageUseCase>((ref) {
  return PickImageUseCase(
    ref.watch(imagePickerRepositoryProvider),
  );
});


// ================================
// Upload State
// ================================

class UploadState {
  final SelectedImageEntity? userImage;
  final SelectedImageEntity? clothingImage;
  final String? errorMessage;

  const UploadState({
    this.userImage,
    this.clothingImage,
    this.errorMessage,
  });

  UploadState copyWith({
    SelectedImageEntity? userImage,
    SelectedImageEntity? clothingImage,
    String? errorMessage,
    bool clearUserImage = false,
    bool clearClothingImage = false,
    bool clearError = false,
  }) {
    return UploadState(
      userImage: clearUserImage ? null : (userImage ?? this.userImage),
      clothingImage: clearClothingImage ? null : (clothingImage ?? this.clothingImage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}


// ================================
// Controller
// Riverpod 3 Notifier
// ================================

class UploadController extends Notifier<UploadState> {


  @override
  UploadState build() {
    return const UploadState();
  }


  Future<void> pickUserImage(ImagePickSource source) async {
    try {
      final pickImage = ref.read(pickImageUseCaseProvider);
      final image = await pickImage(source);
      if (image == null) return;

      state = state.copyWith(
        userImage: image,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Could not pick user image. Please try again.',
      );
    }
  }

  Future<void> pickClothingImage(ImagePickSource source) async {
    try {
      final pickImage = ref.read(pickImageUseCaseProvider);
      final image = await pickImage(source);
      if (image == null) return;

      state = state.copyWith(
        clothingImage: image,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Could not pick clothing image. Please try again.',
      );
    }
  }

  void clearUserImage() {
    state = state.copyWith(clearUserImage: true, clearError: true);
  }
  
  void clearClothingImage() {
    state = state.copyWith(clearClothingImage: true, clearError: true);
  }

  void clearAll() {
    state = const UploadState();
  }

}



// Provider used by UI

final uploadControllerProvider =
NotifierProvider<UploadController, UploadState>(
  UploadController.new,
);