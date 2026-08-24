import 'package:flutter/foundation.dart';
import '../../../../core/services/gemini_service.dart';

class AnalyzeClosetItemUseCase {
  final GeminiService _geminiService = GeminiService();

  Future<Map<String, dynamic>> call(Uint8List imageBytes) async {
    const String prompt = '''
You are a professional AI fashion assistant. You are provided with an image of a clothing item.
Analyze the image and respond with ONLY a valid JSON object, with no markdown formatting, no code fences, and no explanatory text.

Perform the following analyses:
- "category": The type of clothing (e.g., T-Shirt, Jeans, Dress, Sneakers, Jacket, Skirt, Pants, Shorts, Sweater, Hoodie, Coat, Other).
- "color": The dominant color of the item (e.g., Black, Blue, Red, White, Gray, Green, Yellow, Orange, Purple, Pink, Brown, Multi).
- "season": The most appropriate season to wear this (e.g., Summer, Winter, Spring, Fall, All Season).

Use exactly this structure:
{
  "category": "",
  "color": "",
  "season": ""
}
''';

    try {
      final responseText = await _geminiService.generateContent(
        prompt: prompt,
        imageBytes: imageBytes,
      );

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      return _geminiService.extractJson(responseText);
    } catch (e) {
      debugPrint('API Error in AnalyzeClosetItemUseCase: $e');
      // Fallback
      return {
        "category": "T-Shirt",
        "color": "Black",
        "season": "All Season"
      };
    }
  }
}
