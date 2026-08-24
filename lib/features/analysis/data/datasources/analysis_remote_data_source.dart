import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../../../core/services/gemini_service.dart';
import '../models/analysis_model.dart';

class AnalysisParsingException implements Exception {
  final String message;
  const AnalysisParsingException(this.message);
  @override
  String toString() => 'AnalysisParsingException: $message';
}

class AnalysisResponseException implements Exception {
  final String message;
  const AnalysisResponseException(this.message);
  @override
  String toString() => 'AnalysisResponseException: $message';
}

abstract class AnalysisRemoteDataSource {
  Future<AnalysisModel> analyzeImage(Uint8List imageBytes);
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  const AnalysisRemoteDataSourceImpl();

  static Uint8List _compressImage(Uint8List rawBytes) {
    try {
      final image = img.decodeImage(rawBytes);
      if (image == null) return rawBytes;

      img.Image resized = image;
      if (image.width > 1024 || image.height > 1024) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height >= image.width ? 1024 : null,
          interpolation: img.Interpolation.average,
        );
      }

      final compressed = img.encodeJpg(resized, quality: 85);
      return Uint8List.fromList(compressed);
    } catch (_) {
      return rawBytes;
    }
  }

  static const String _prompt = '''
Analyze the clothing item in this image and respond with ONLY a valid JSON
object, with no markdown formatting, no code fences, and no explanatory text.

Use exactly this structure:
{
  "clothingType": "",
  "color": "",
  "pattern": "",
  "material": "",
  "season": "",
  "occasion": "",
  "confidence": 0.95
}

Rules:
- "clothingType", "color", "pattern", "material", "season", and "occasion"
  must be short descriptive strings.
- "confidence" must be a number between 0 and 1 representing how certain
  you are of the clothingType classification.
- Do not include any text before or after the JSON object.
''';

  @override
  Future<AnalysisModel> analyzeImage(Uint8List imageBytes) async {
    final geminiService = GeminiService();
    final compressedBytes = _compressImage(imageBytes);

    final responseText = await geminiService.generateContent(
      prompt: _prompt,
      imageBytes: compressedBytes,
    );

    if (responseText == null || responseText.trim().isEmpty) {
      throw const AnalysisResponseException(
        'Gemini returned an empty response for the image analysis request.',
      );
    }

    try {
      final jsonMap = geminiService.extractJson(responseText);
      return AnalysisModel.fromJson(jsonMap);
    } catch (e) {
      throw AnalysisParsingException(
        'Failed to parse analysis response: $e\nRaw: $responseText',
      );
    }
  }
}