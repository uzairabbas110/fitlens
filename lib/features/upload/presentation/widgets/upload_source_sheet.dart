import 'package:flutter/material.dart';

import '../../domain/repositories/image_picker_repository.dart';


// Bottom sheet to select image source
Future<ImagePickSource?> showUploadSourceSheet(
    BuildContext context) {

  return showModalBottomSheet<ImagePickSource>(
    context: context,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),

    builder: (context) {

      return SafeArea(
        child: Wrap(
          children: [

            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
              ),

              title: const Text(
                'Take a photo',
              ),

              onTap: () {
                Navigator.of(context)
                    .pop(ImagePickSource.camera);
              },
            ),


            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
              ),

              title: const Text(
                'Choose from gallery',
              ),

              onTap: () {
                Navigator.of(context)
                    .pop(ImagePickSource.gallery);
              },
            ),

          ],
        ),
      );
    },
  );
}