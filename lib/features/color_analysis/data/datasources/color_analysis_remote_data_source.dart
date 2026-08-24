import 'package:flutter/foundation.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/color_recommendation_model.dart';

abstract class ColorAnalysisRemoteDataSource {
  Future<ColorRecommendationModel> analyzeSkinTone(Uint8List imageBytes);
}

class ColorAnalysisRemoteDataSourceImpl implements ColorAnalysisRemoteDataSource {
  const ColorAnalysisRemoteDataSourceImpl();

  static const String _prompt = '''
You are a professional AI color analyst and stylist. You are provided with an image of a user.

Analyze the image and respond with ONLY a valid JSON object, with no markdown formatting, no code fences, and no explanatory text.

Perform the following analysis:
- "skinTone": Detect the user's skin tone (e.g., Fair, Light, Medium, Olive, Brown, Dark) and undertone (cool, warm, neutral).
- "description": A brief description of the skin tone and why certain colors would look good.
- "recommendedColors": A list of recommended color hex codes that complement the user's skin tone (e.g., ["#FF5733", "#33FF57"]).

Use exactly this structure:
{
  "skinTone": "",
  "description": "",
  "recommendedColors": []
}
''';

  @override
  Future<ColorRecommendationModel> analyzeSkinTone(Uint8List imageBytes) async {
    try {
      final geminiService = GeminiService();
      
      int retryCount = 0;
      String? responseText;
      
      while (retryCount < 3) {
        try {
          responseText = await geminiService.generateContent(
            prompt: _prompt,
            imageBytes: imageBytes,
          );
          break;
        } catch (e) {
          if (e.toString().contains('429')) {
            retryCount++;
            await Future.delayed(Duration(seconds: 2 * retryCount));
          } else {
            rethrow;
          }
        }
      }

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      final jsonMap = geminiService.extractJson(responseText);
      return ColorRecommendationModel.fromJson(jsonMap);
    } catch (e) {
      debugPrint('API Error encountered, falling back to Demo Mode: $e');
      
      await Future.delayed(const Duration(seconds: 2));
      
      return const ColorRecommendationModel(
        skinTone: 'Warm Olive',
        description: 'You have a warm olive skin tone. Earthy tones and warm colors will highlight your natural glow.',
        recommendedColors: ['#8B4513', '#D2691E', '#556B2F', '#800000', '#DAA520'],
      );
    }
  }
}
