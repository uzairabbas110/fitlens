import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../closet/presentation/providers/closet_provider.dart';
import '../../data/models/capsule_model.dart';

class CapsuleState {
  final CapsuleWardrobe? capsule;
  final bool isLoading;
  final String? error;

  const CapsuleState({
    this.capsule,
    this.isLoading = false,
    this.error,
  });

  CapsuleState copyWith({
    CapsuleWardrobe? capsule,
    bool? isLoading,
    String? error,
  }) {
    return CapsuleState(
      capsule: capsule ?? this.capsule,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CapsuleNotifier extends Notifier<CapsuleState> {
  final GeminiService _geminiService = GeminiService();

  @override
  CapsuleState build() {
    return const CapsuleState();
  }

  Future<void> generateCapsule({
    String season = 'All Season',
    String vibe = 'Quiet Luxury & Minimalist',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Gather user's existing closet items
      final closetState = ref.read(closetProvider);
      final closetItems = closetState.value ?? [];
      
      final closetDescription = closetItems.isNotEmpty
          ? closetItems.map((e) => '- ${e.category}: ${e.color} (${e.season})').join('\n')
          : 'User has no uploaded items yet. Recommend 10 essential foundational pieces for a timeless wardrobe.';

      final prompt = '''
You are FitLens VIP Lead Haute Couture Stylist.
Build a comprehensive "10x30 Capsule Wardrobe" for the user.
Concept: Select 10 core versatile items that mix & match to create 30 distinct outfits.

Parameters:
- Target Season: $season
- Target Aesthetic / Vibe: $vibe
- User's Current Closet Items:
$closetDescription

Return a valid JSON object with the exact following schema:
{
  "season": "$season",
  "vibe": "$vibe",
  "colorPaletteSummary": "String summarizing harmonious core colors (e.g. Crisp White, Charcoal, Camel, Navy)",
  "corePieces": [
    {
      "id": "item_1",
      "name": "Item Name (e.g. Tailored Cream Blazer)",
      "category": "Top | Bottom | Layer | Shoe | Accessory",
      "color": "Color name",
      "styleTip": "How to style this piece"
    }
  ],
  "outfitFormulas": [
    {
      "outfitNumber": 1,
      "title": "Outfit name (e.g. Effortless Boardroom Power)",
      "occasion": "Work / Business Casual",
      "itemNames": ["Tailored Cream Blazer", "Silk Navy Blouse", "Charcoal Wide-Leg Trousers", "Pointed Nude Loafers"],
      "whyItWorks": "Explanation of silhouette balance and color harmony",
      "stylingTip": "Roll up blazer sleeves slightly for an effortless high-fashion silhouette."
    }
  ]
}

Ensure all JSON keys and values are strictly valid JSON without markdown wrapping.
''';

      final response = await _geminiService.generateContent(
        prompt: prompt,
        useCache: true,
      );

      if (response == null || response.isEmpty) {
        throw Exception('Unable to generate capsule wardrobe. Please try again.');
      }

      final jsonMap = _geminiService.extractJson(response);
      final capsuleWardrobe = CapsuleWardrobe.fromJson(jsonMap);

      state = state.copyWith(
        capsule: capsuleWardrobe,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      );
    }
  }
}

final capsuleProvider = NotifierProvider<CapsuleNotifier, CapsuleState>(CapsuleNotifier.new);
