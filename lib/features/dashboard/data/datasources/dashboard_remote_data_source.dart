import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../../../core/services/gemini_service.dart';
import '../models/dashboard_result_model.dart';

abstract class DashboardRemoteDataSource {
  Future<FitLensResultModel> analyzeMatch({
    required Uint8List? userImageBytes,
    required Uint8List? clothingImageBytes,
    String? weatherContext,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl();

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
You are a professional AI fashion assistant and stylist. You are provided with TWO images:
1. The first image is a photo of the user.
2. The second image is a photo of a clothing item they want to buy.

Analyze both images and respond with ONLY a valid JSON object, with no markdown formatting, no code fences, and no explanatory text.

Perform the following analyses:
- "skinTone": Detect the user's skin tone (e.g., Fair, Light, Medium, Olive, Brown, Dark).
- "estimatedSize": Estimate the user's body size based on proportions (e.g., S, M, L, XL, XXL).
- "recommendedSize": The best clothing size for them for this specific item.
- "sizeMatchScore": A score from 0 to 100 on how well this clothing item type matches their body type.
- "colorMatchScore": A score from 0 to 100 on how well the clothing color matches their skin tone.
- "clothingTexture": Describe the fabric texture of the clothing.
- "clothingQuality": Describe the visual quality/sharpness of the clothing item.
- "qualityScore": A score from 0 to 100 on the quality of the garment.
- "buyAdvice": Final recommendation (Highly Recommended, Recommended, Consider Alternatives, Not Recommended).
- "reasoning": A brief paragraph explaining why you gave this buy advice.

Use exactly this structure:
{
  "skinTone": "",
  "estimatedSize": "",
  "recommendedSize": "",
  "sizeMatchScore": 95,
  "colorMatchScore": 90,
  "clothingTexture": "",
  "clothingQuality": "",
  "qualityScore": 85,
  "buyAdvice": "",
  "reasoning": ""
}
''';

  @override
  Future<FitLensResultModel> analyzeMatch({
    required Uint8List? userImageBytes,
    required Uint8List? clothingImageBytes,
    String? weatherContext,
  }) async {
    String dynamicPrompt = "You are a professional AI fashion assistant and stylist. ";
    if (userImageBytes != null && clothingImageBytes != null) {
       dynamicPrompt += "You are provided with TWO images: 1. A photo of the user. 2. A photo of a clothing item.\n\n";
    } else if (userImageBytes != null) {
       dynamicPrompt += "You are provided with ONE image: A photo of the user.\n\n";
    } else if (clothingImageBytes != null) {
       dynamicPrompt += "You are provided with ONE image: A photo of a clothing item.\n\n";
    } else {
       throw Exception("At least one image must be provided.");
    }
    
    if (weatherContext != null) {
      dynamicPrompt += "Current Weather Context: $weatherContext\nPlease take this weather into consideration for your buyAdvice and reasoning.\n\n";
    }
    
    final originalPromptBody = _prompt.substring(_prompt.indexOf("Analyze both images"));
    final newPromptBody = originalPromptBody.replaceFirst("Analyze both images", "Analyze the provided image(s)");
    
    final fullPrompt = dynamicPrompt + newPromptBody;

    final images = <Uint8List>[];
    if (userImageBytes != null) images.add(_compressImage(userImageBytes));
    if (clothingImageBytes != null) images.add(_compressImage(clothingImageBytes));

    final geminiService = GeminiService();
    final responseText = await geminiService.generateContent(
      prompt: fullPrompt,
      multipleImages: images.isNotEmpty ? images : null,
    );

    if (responseText == null || responseText.trim().isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    final jsonMap = geminiService.extractJson(responseText);
    return FitLensResultModel.fromJson(jsonMap);
  }
}

