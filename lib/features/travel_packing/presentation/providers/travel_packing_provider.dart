import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../closet/presentation/providers/closet_provider.dart';
import '../../data/models/travel_packing_model.dart';

class TravelPackingState {
  final TravelTripPlan? tripPlan;
  final bool isLoading;
  final String? error;

  const TravelPackingState({
    this.tripPlan,
    this.isLoading = false,
    this.error,
  });

  TravelPackingState copyWith({
    TravelTripPlan? tripPlan,
    bool? isLoading,
    String? error,
  }) {
    return TravelPackingState(
      tripPlan: tripPlan ?? this.tripPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TravelPackingNotifier extends Notifier<TravelPackingState> {
  final GeminiService _geminiService = GeminiService();

  @override
  TravelPackingState build() {
    return const TravelPackingState();
  }

  void toggleItem(String itemId) {
    if (state.tripPlan == null) return;
    final currentList = state.tripPlan!.checklist;
    final updatedList = currentList.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();

    state = state.copyWith(
      tripPlan: state.tripPlan!.copyWith(checklist: updatedList),
    );
  }

  Future<void> generateTripPlan({
    required String destination,
    required int durationDays,
    required String tripType,
    String genderPreference = 'Women',
    String? activities,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final closetState = ref.read(closetProvider);
      final closetItems = closetState.value ?? [];
      final closetSummary = closetItems.isNotEmpty
          ? closetItems.map((e) => '- ${e.category} (${e.color})').join(', ')
          : 'Standard versatile traveler wardrobe';

      final prompt = '''
You are FitLens VIP Elite Travel Stylist & Luggage Optimization Specialist.
Create an intelligent, ultra-efficient packing checklist and a day-by-day mix-and-match outfit itinerary for a trip.

Trip Details:
- Destination: $destination
- Duration: $durationDays Days
- Trip Type / Vibe: $tripType
- Style / Gender Preference: $genderPreference (CRITICAL: Curate and tailor all clothing pieces, silhouettes, tops, bottoms, shoes, and accessories specifically for $genderPreference fashion!)
- Planned Activities / Notes: ${activities ?? 'Sightseeing, dining, leisure'}
- User's Closet Context: $closetSummary

Return a valid JSON object strictly matching this schema:
{
  "destination": "$destination",
  "durationDays": $durationDays,
  "tripType": "$tripType",
  "genderPreference": "$genderPreference",
  "climateSummary": "Expected weather summary (e.g. Sunny 26°C with cool evenings)",
  "luggageAdvice": "Concise luggage recommendation (e.g. 1 Carry-on trolley + 1 personal tote)",
  "checklist": [
    {
      "id": "item_1",
      "name": "Item name (e.g. Breathable White Linen Shirt)",
      "category": "Tops | Bottoms | Outerwear | Shoes | Accessories | Essentials",
      "quantity": 1,
      "isChecked": false
    }
  ],
  "dayByDayOutfits": [
    {
      "dayNumber": 1,
      "dayTitle": "Day 1: Arrival & Exploring Old Town",
      "activity": "Walking & Casual Dinner",
      "temperatureExpected": "24°C / 75°F Mild",
      "outfitPieces": ["Linen Shirt", "Tailored Chino Shorts", "White Leather Sneakers"],
      "eveningLayerTip": "Throw lightweight cardigan over shoulders for sunset."
    }
  ]
}

Ensure all JSON keys and formatting are strictly compliant JSON without markdown blocks.
''';

      final response = await _geminiService.generateContent(
        prompt: prompt,
        useCache: true,
      );

      if (response == null || response.isEmpty) {
        throw Exception('Failed to generate trip plan. Please try again.');
      }

      final jsonMap = _geminiService.extractJson(response);
      final tripPlan = TravelTripPlan.fromJson(jsonMap);

      state = state.copyWith(
        tripPlan: tripPlan,
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

final travelPackingProvider = NotifierProvider<TravelPackingNotifier, TravelPackingState>(TravelPackingNotifier.new);
