import 'package:flutter/material.dart';

import '../../domain/entities/selected_image_entity.dart';

class ImagePreviewWidget extends StatelessWidget {
  final SelectedImageEntity? selectedImage;

  const ImagePreviewWidget({
    super.key,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: selectedImage != null
          ? Image.memory(
        selectedImage!.bytes,
        fit: BoxFit.cover,
      )
          : const Center(
        child: Icon(
          Icons.image_outlined,
          size: 56,
        ),
      ),
    );
  }
}