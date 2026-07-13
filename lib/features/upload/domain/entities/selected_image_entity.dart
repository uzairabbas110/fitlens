import 'dart:typed_data';

class SelectedImageEntity {
  final Uint8List bytes;
  final String fileName;

  const SelectedImageEntity({
    required this.bytes,
    required this.fileName,
  });
}