import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/upload_provider.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/upload_source_sheet.dart';


class UploadScreen extends ConsumerWidget {

  const UploadScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final uploadState =
    ref.watch(uploadControllerProvider);

    final controller =
    ref.read(uploadControllerProvider.notifier);



    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Analyze Outfit',
        ),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.stretch,


          children: [

            ImagePreviewWidget(
              selectedImage:
              uploadState.selectedImage,
            ),


            const SizedBox(height: 20),



            FilledButton.icon(

              onPressed: () async {

                final source =
                await showUploadSourceSheet(
                  context,
                );


                if (source != null) {

                  await controller.pickImage(
                    source,
                  );

                }

              },


              icon: const Icon(
                Icons.add_a_photo,
              ),


              label: const Text(
                'Select Image',
              ),

            ),



            const SizedBox(height: 15),



            if (uploadState.errorMessage != null)

              Text(

                uploadState.errorMessage!,

                textAlign:
                TextAlign.center,

                style: const TextStyle(
                  color: Colors.red,
                ),

              ),



            if (uploadState.selectedImage != null)

              TextButton.icon(

                onPressed:
                controller.clearSelection,


                icon: const Icon(
                  Icons.close,
                ),


                label: const Text(
                  'Remove Image',
                ),

              ),

          ],
        ),
      ),
    );
  }
}