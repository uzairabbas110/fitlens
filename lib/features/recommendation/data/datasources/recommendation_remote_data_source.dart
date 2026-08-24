import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../../../analysis/domain/entities/analysis_entity.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/recommendation_model.dart';

/// Thrown when the Gemini API response cannot be parsed into a valid
/// [RecommendationModel].
class RecommendationParsingException implements Exception {
  final String message;

  const RecommendationParsingException(this.message);

  @override
  String toString() => 'RecommendationParsingException: $message';
}

/// Thrown when the Gemini API returns an empty or unusable response.
class RecommendationResponseException implements Exception {
  final String message;

  const RecommendationResponseException(this.message);

  @override
  String toString() => 'RecommendationResponseException: $message';
}

/// Defines the contract for generating an outfit recommendation from a
/// clothing image and its prior analysis.
abstract class RecommendationRemoteDataSource {
  Future<RecommendationModel> generateRecommendation({
    required Uint8List imageBytes,
    required AnalysisEntity analysis,
  });
}

/// Concrete implementation of [RecommendationRemoteDataSource] backed by
/// the Google Gemini REST API via http.
class RecommendationRemoteDataSourceImpl implements RecommendationRemoteDataSource {
  const RecommendationRemoteDataSourceImpl();

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

  @override
  Future<RecommendationModel> generateRecommendation({
    required Uint8List imageBytes,
    required AnalysisEntity analysis,
  }) async {
    final prompt = _buildPrompt(analysis);
    
    try {
      final geminiService = GeminiService();
      final compressedBytes = _compressImage(imageBytes);
      
      final responseText = await geminiService.generateContent(
        prompt: prompt,
        imageBytes: compressedBytes,
      );

      if (responseText == null || responseText.trim().isEmpty) {
        throw const RecommendationResponseException(
          'Gemini returned an empty response for the recommendation request.',
        );
      }

      final jsonMap = geminiService.extractJson(responseText);
      return RecommendationModel.fromJson(jsonMap);
    } catch (e) {
      if (e is RecommendationParsingException || e is RecommendationResponseException) {
        rethrow;
      }
      throw RecommendationResponseException(
        'Failed to generate recommendation: $e'
      );
    }
  }

  /// Builds the prompt sent to Gemini, combining the prior analysis
  /// result with strict instructions to return only JSON.
  String _buildPrompt(AnalysisEntity analysis) {
    return '''
You are a professional fashion stylist. A clothing item has already been
analyzed with the following results:

- Clothing Type: ${analysis.clothingType}
- Color: ${analysis.color}
- Pattern: ${analysis.pattern}
- Material: ${analysis.material}
- Season: ${analysis.season}
- Occasion: ${analysis.occasion}

Using both the image provided and the analysis above, recommend a complete
outfit that pairs well with this clothing item.

Respond with ONLY a valid JSON object, with no markdown formatting, no code
fences, and no explanatory text. Use exactly this structure:
{
  "recommendedTop": "",
  "recommendedBottom": "",
  "recommendedFootwear": "",
  "recommendedAccessory": "",
  "styleDescription": "",
  "colorHarmony": "",
  "reason": "",
  "confidence": 0.95
}

Rules:
- "recommendedTop", "recommendedBottom", "recommendedFootwear", and
  "recommendedAccessory" must each be a short, specific clothing item
  recommendation.
- "styleDescription" must briefly describe the overall style being achieved.
- "colorHarmony" must briefly describe how the recommended colors work
  together with the analyzed item.
- "reason" must briefly explain why this recommendation suits the item.
- "confidence" must be a number between 0 and 1 representing how confident
  you are in this recommendation.
- Do not include any text before or after the JSON object.
''';
  }
}