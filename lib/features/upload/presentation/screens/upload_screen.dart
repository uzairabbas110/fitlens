import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/floating_fashion_background.dart';
import '../providers/upload_provider.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/upload_source_sheet.dart';

class UploadScreen extends ConsumerWidget {
  final String feature;
  const UploadScreen({super.key, this.feature = 'all'});

  String get _title {
    switch (feature) {
      case 'skin_tone': return 'Skin Tone Analysis';
      case 'size': return 'Size Recommendation';
      case 'quality': return 'Quality Analysis';
      case 'buy': return 'Buy Recommendation';
      default: return 'New Analysis';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);
    final controller = ref.read(uploadControllerProvider.notifier);

    final needsUserImage = feature == 'skin_tone' || feature == 'size' || feature == 'buy' || feature == 'all';
    final needsClothingImage = feature == 'quality' || feature == 'size' || feature == 'buy' || feature == 'all';

    final hasRequiredUserImage = !needsUserImage || uploadState.userImage != null;
    final hasRequiredClothingImage = !needsClothingImage || uploadState.clothingImage != null;

    final canAnalyze = hasRequiredUserImage && hasRequiredClothingImage;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FloatingFashionBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (needsUserImage) ...[
              Text(
                needsClothingImage ? '1. Upload Your Photo' : 'Upload Your Photo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Used for skin tone detection and size estimation.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (uploadState.userImage != null) ...[
                ImagePreviewWidget(selectedImage: uploadState.userImage),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: controller.clearUserImage,
                  icon: const Icon(Icons.close),
                  label: const Text('Remove user photo'),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    final source = await showUploadSourceSheet(context);
                    if (source != null) {
                      await controller.pickUserImage(source);
                    }
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Select Your Photo'),
                ),
              ],
            ],
            
            if (needsUserImage && needsClothingImage) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
            ],

            if (needsClothingImage) ...[
              Text(
                needsUserImage ? '2. Upload Clothing Image' : 'Upload Clothing Image',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Used for texture, color, and quality analysis.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (uploadState.clothingImage != null) ...[
                ImagePreviewWidget(selectedImage: uploadState.clothingImage),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: controller.clearClothingImage,
                  icon: const Icon(Icons.close),
                  label: const Text('Remove clothing image'),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    final source = await showUploadSourceSheet(context);
                    if (source != null) {
                      await controller.pickClothingImage(source);
                    }
                  },
                  icon: const Icon(Icons.checkroom_outlined),
                  label: const Text('Select Clothing Image'),
                ),
              ],
            ],

            const SizedBox(height: 24),
            if (uploadState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  uploadState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            FilledButton.icon(
              onPressed: canAnalyze ? () {
                context.push(
                  '/analysis', 
                  extra: {
                    'userImage': uploadState.userImage?.bytes,
                    'clothingImage': uploadState.clothingImage?.bytes,
                    'feature': feature,
                  }
                );
              } : null,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Analyze Matches'),
            ),
          ],
        ),
      ),
    )),
  );
}
}