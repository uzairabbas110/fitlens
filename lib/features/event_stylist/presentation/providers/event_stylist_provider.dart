import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../closet/presentation/providers/closet_provider.dart';
import '../../data/models/event_styling_model.dart';

class EventStylistState {
  final EventStylingResult? result;
  final bool isLoading;
  final String? error;

  const EventStylistState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  EventStylistState copyWith({
    EventStylingResult? result,
    bool? isLoading,
    String? error,
  }) {
    return EventStylistState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EventStylistNotifier extends Notifier<EventStylistState> {
  final GeminiService _geminiService = GeminiService();

  @override
  EventStylistState build() {
    return const EventStylistState();
  }

  Future<void> generateEventOutfit({
    required String eventName,
    required String dressCode,
    String? venueOrVibe,
    String? preferredColor,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final closetState = ref.read(closetProvider);
      final closetItems = closetState.value ?? [];
      final closetSummary = closetItems.isNotEmpty
          ? closetItems.map((e) => '- ${e.category}: ${e.color}').join(', ')
          : 'User has no wardrobe items yet. Suggest timeless designer combinations.';

      final prompt = '''
You are FitLens VIP Lead Red-Carpet & High-Profile Event Stylist.
Create a complete, unforgettable outfit styling for an upcoming occasion.

Event Details:
- Event Occasion: $eventName
- Dress Code: $dressCode
- Venue / Setting / Vibe: ${venueOrVibe ?? 'High-end social or professional atmosphere'}
- Preferred Color Palette: ${preferredColor ?? 'Flattering modern neutrals or rich jewel tones'}
- User Wardrobe Available: $closetSummary

Return a valid JSON object matching this exact schema:
{
  "eventName": "$eventName",
  "dressCode": "$dressCode",
  "styleHeadline": "Punchy Haute Couture Style Statement (e.g. Sharp Monochrome Elegance)",
  "colorHarmonyAnalysis": "Detailed analysis of why these colors convey power, warmth, or sophistication for this event",
  "outfitBreakdown": [
    {
      "category": "Top / Shirt",
      "itemName": "Specific item description (e.g. Silk Champagne Button-down)",
      "color": "Champagne / Warm Ivory",
      "details": "Open collar with structured French cuffs"
    },
    {
      "category": "Bottom / Trouser / Dress",
      "itemName": "Specific item description",
      "color": "Color",
      "details": "Details on fit and draping"
    },
    {
      "category": "Outerwear / Layer",
      "itemName": "Blazer, Coat, or Shawl",
      "color": "Color",
      "details": "Tailoring notes"
    },
    {
      "category": "Footwear",
      "itemName": "Specific shoes",
      "color": "Color",
      "details": "Material and silhouette (e.g. Pointed Suede Pumps or Italian Chelsea Boots)"
    }
  ],
  "accessoriesAndJewelry": [
    "Minimalist gold signet ring",
    "Structured textured leather clutch",
    "Slim leather belt with brushed gold buckle"
  ],
  "groomingAndFragranceTip": "Hair, skin finish & perfume scent profile recommendation",
  "confidenceAndPostureTip": "Key physical presence advice for entering this event"
}

Strictly return valid JSON without markdown fences.
''';

      final response = await _geminiService.generateContent(
        prompt: prompt,
        useCache: true,
      );

      if (response == null || response.isEmpty) {
        throw Exception('Failed to generate event styling. Please try again.');
      }

      final jsonMap = _geminiService.extractJson(response);
      final stylingResult = EventStylingResult.fromJson(jsonMap);

      state = state.copyWith(
        result: stylingResult,
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

final eventStylistProvider = NotifierProvider<EventStylistNotifier, EventStylistState>(EventStylistNotifier.new);
