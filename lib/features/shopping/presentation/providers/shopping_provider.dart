import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/gemini_service.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../domain/entities/shop_item_entity.dart';
import 'dart:typed_data';

class ShoppingNotifier extends AsyncNotifier<List<ShopItemEntity>> {
  @override
  Future<List<ShopItemEntity>> build() async {
    return [];
  }

  Future<void> findShoppingLinks({required String imageUrl, required String description}) async {
    state = const AsyncValue.loading();
    try {
      // 1. Get Location Context
      String locationContext = "Unknown location";
      try {
        final weather = await ref.read(weatherProvider.future);
        locationContext = weather.city;
      } catch (e) {
        // If weather fails (e.g. permissions denied), we proceed with unknown location
      }

      // 2. Fetch image bytes from URL or decode base64
      Uint8List imageBytes;
      if (imageUrl.startsWith('data:image')) {
        final base64Image = imageUrl.split(',').last;
        imageBytes = base64Decode(base64Image);
      } else {
        final imageResponse = await http.get(Uri.parse(imageUrl));
        if (imageResponse.statusCode != 200) {
          throw Exception('Failed to download image for analysis.');
        }
        imageBytes = imageResponse.bodyBytes;
      }

      // 3. Prompt Gemini
      final prompt = '''
You are an expert fashion personal shopper.
The user is located in: $locationContext.
Look at the attached image of an outfit, and read the original poster's description: "$description".
Identify the 3 most prominent pieces of clothing in the image.
For each item, generate a realistic, shoppable link where the user can buy a similar item from an eCommerce store that ships to or is popular in their location ($locationContext).
For example, if they are in Pakistan, use Daraz, Gul Ahmed, Sapphire, Khaadi, or Outfitters. If in the USA, use Amazon, Zara, H&M, etc.

Return the response EXACTLY as a valid JSON array of objects. Do not include markdown formatting or backticks.
Format:
[
  {
    "item_name": "Black Leather Jacket",
    "brand": "Zara",
    "url": "https://www.zara.com/..."
  }
]
''';

      final geminiService = GeminiService();
      final responseText = await geminiService.generateContent(
        prompt: prompt,
        imageBytes: imageBytes,
      );

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      // Clean markdown if Gemini hallucinates it
      String cleanJson = responseText;
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }

      final List<dynamic> jsonArray = jsonDecode(cleanJson.trim());
      final links = jsonArray.map((e) => ShopItemEntity.fromJson(e)).toList();

      state = AsyncValue.data(links);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final shoppingProvider = AsyncNotifierProvider<ShoppingNotifier, List<ShopItemEntity>>(() {
  return ShoppingNotifier();
});
