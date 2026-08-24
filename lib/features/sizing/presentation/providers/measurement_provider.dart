import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/services/cloudflare_storage_service.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/measurement_entity.dart';
import '../../domain/services/size_calculator_service.dart';

class MeasurementNotifier extends AsyncNotifier<MeasurementEntity?> {
  @override
  Future<MeasurementEntity?> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('measurements')
          .doc('latest')
          .get();

      if (doc.exists && doc.data() != null) {
        return MeasurementEntity.fromJson(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  /// Compress and scale down large phone camera images to optimize Gemini processing
  Uint8List _compressImage(Uint8List rawBytes) {
    try {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) return rawBytes;

      img.Image processed = decoded;
      const int maxDim = 1024;
      if (decoded.width > maxDim || decoded.height > maxDim) {
        if (decoded.width >= decoded.height) {
          processed = img.copyResize(decoded, width: maxDim);
        } else {
          processed = img.copyResize(decoded, height: maxDim);
        }
      }
      return Uint8List.fromList(img.encodeJpg(processed, quality: 85));
    } catch (_) {
      return rawBytes;
    }
  }

  /// Analyzes a user's full-body photo using AI vision to extract measurements and style profile
  Future<void> analyzeBodyProportions(Uint8List rawImageBytes) async {
    state = const AsyncValue.loading();
    try {
      final imageBytes = _compressImage(rawImageBytes);

      const prompt = '''
You are an expert fashion stylist and tailor.
Analyze the attached full-body photo of the user. Estimate their exact body measurements (chest_inches, waist_inches, hips_inches) as realistic numbers.
Estimate their general body type (e.g., Athletic, Slim, Curvy, Broad Shoulders, Hourglass, Rectangle) and standard clothing size (e.g., Small (S), Medium (M), Large (L)).
Provide 2-3 concise sentences of personalized style advice on what fits, necklines, and silhouettes flatter them best.

Return ONLY a valid JSON object matching this schema:
{
  "estimated_size": "Medium (M)",
  "body_type": "Athletic with broad shoulders",
  "chest_inches": 40.0,
  "waist_inches": 32.0,
  "hips_inches": 38.0,
  "advice": "Opt for structured jackets and tailored fits to complement your shoulders. V-necks and vertical silhouettes will balance your proportions."
}
''';

      final geminiService = GeminiService();
      final responseText = await geminiService.generateContent(
        prompt: prompt,
        imageBytes: imageBytes,
      );

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception('AI analysis service returned an empty response. Please try again.');
      }

      final jsonMap = geminiService.extractJson(responseText);

      // Upload compressed photo to storage asynchronously
      final user = ref.read(authStateChangesProvider).value;
      String? imageUrl;
      if (user != null) {
        final fileName = 'measurement_${DateTime.now().millisecondsSinceEpoch}.jpg';
        try {
          imageUrl = await CloudflareStorageService.uploadImage(imageBytes, fileName);
        } catch (_) {}
      }

      jsonMap['image_url'] = imageUrl;

      // Compute brand recommendations via local rules engine
      final chest = (jsonMap['chest_inches'] as num?)?.toDouble();
      final waist = (jsonMap['waist_inches'] as num?)?.toDouble();
      final generatedBrands = SizeCalculatorService.getRecommendations(chest, waist);
      jsonMap['brand_recommendations'] = generatedBrands;

      final entity = MeasurementEntity.fromJson(jsonMap);

      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('measurements')
              .doc('latest')
              .set(entity.toJson());
        } catch (_) {}
      }

      // Record consumed demo try in subscription provider
      ref.read(subscriptionProvider.notifier).incrementSizingTries();

      state = AsyncValue.data(entity);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Calculates size, recommendations, and advice directly from manual numeric inputs
  Future<void> calculateFromManualInputs({
    double? heightCm,
    double? weightKg,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Convert cm to inches if provided (or assume inches if already in range)
      double? toInches(double? val) {
        if (val == null) return null;
        return val > 50 ? double.parse((val / 2.54).toStringAsFixed(1)) : val;
      }

      final chestInches = toInches(chestCm);
      final waistInches = toInches(waistCm);
      final hipsInches = toInches(hipsCm);

      String estimatedSize = 'Medium (M)';
      if (chestInches != null) {
        if (chestInches < 37) {
          estimatedSize = 'Small (S)';
        } else if (chestInches <= 41) {
          estimatedSize = 'Medium (M)';
        } else if (chestInches <= 44) {
          estimatedSize = 'Large (L)';
        } else {
          estimatedSize = 'Extra Large (XL)';
        }
      }

      String bodyType = 'Proportional';
      if (chestInches != null && waistInches != null) {
        if (chestInches - waistInches >= 6) {
          bodyType = 'Athletic / V-Taper';
        } else if (waistInches > chestInches) {
          bodyType = 'Round / Oval';
        } else {
          bodyType = 'Rectangle / Slim';
        }
      }

      final brands = SizeCalculatorService.getRecommendations(chestInches, waistInches);

      final entity = MeasurementEntity(
        estimatedSize: estimatedSize,
        bodyType: bodyType,
        brandRecommendations: brands,
        advice: 'Based on your measurements, tailored and slim-fit cuts will provide a sharp silhouette. Check individual brand charts for specific garment fit.',
        chestInches: chestInches,
        waistInches: waistInches,
        hipsInches: hipsInches,
      );

      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('measurements')
              .doc('latest')
              .set(entity.toJson());
        } catch (_) {}
      }

      state = AsyncValue.data(entity);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

final measurementProvider = AsyncNotifierProvider<MeasurementNotifier, MeasurementEntity?>(() {
  return MeasurementNotifier();
});

