import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal();

  /// Optional client-side API key passed via compile-time environment variable (`--dart-define=GEMINI_API_KEY=...`)
  /// Defaults to empty to prevent client-side credential exposure (all calls routed via secure server proxy)
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Preferred available Gemini models in priority order
  static const List<String> _preferredModels = [
    'gemini-flash-lite-latest',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  /// Generates a unique hash for caching AI responses
  String _generateCacheKey(String prompt, Uint8List? imageBytes, List<Uint8List>? multipleImages) {
    var bytesBuilder = BytesBuilder();
    bytesBuilder.add(utf8.encode(prompt));

    if (imageBytes != null) {
      bytesBuilder.add(imageBytes);
    }

    if (multipleImages != null) {
      for (var img in multipleImages) {
        bytesBuilder.add(img);
      }
    }

    final digest = sha256.convert(bytesBuilder.toBytes());
    return digest.toString();
  }

  /// Optional direct cloud call if environment key is provided at compile time
  Future<String?> _callGeminiDirect({
    required List<Map<String, dynamic>> parts,
    List<Map<String, dynamic>>? contents,
  }) async {
    if (_envApiKey.isEmpty) {
      return null;
    }

    final payload = contents ??
        [
          {
            'parts': parts,
          }
        ];

    for (final model in _preferredModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_envApiKey',
        );

        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'contents': payload,
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = jsonResponse['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final firstCandidate = candidates.first as Map<String, dynamic>;
            final content = firstCandidate['content'] as Map<String, dynamic>?;
            final resParts = content?['parts'] as List<dynamic>?;
            if (resParts != null && resParts.isNotEmpty) {
              final text = resParts.first['text'] as String?;
              if (text != null && text.isNotEmpty) {
                return text;
              }
            }
          }
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Sends a prompt and optional image bytes to Gemini AI via secure backend proxy.
  Future<String?> generateContent({
    required String prompt,
    Uint8List? imageBytes,
    List<Uint8List>? multipleImages,
    bool useCache = true,
  }) async {
    String? cacheKey;
    final firestore = FirebaseFirestore.instance;

    if (useCache) {
      cacheKey = _generateCacheKey(prompt, imageBytes, multipleImages);
      try {
        final doc = await firestore.collection('ai_cache').doc(cacheKey).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data.containsKey('response')) {
            final cachedResp = data['response'] as String;
            if (cachedResp.isNotEmpty) {
              return cachedResp;
            }
          }
        }
      } catch (_) {}
    }

    // 1. Check if compile-time direct key is provided
    if (_envApiKey.isNotEmpty) {
      final parts = <Map<String, dynamic>>[
        {'text': prompt},
      ];

      if (imageBytes != null) {
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Encode(imageBytes),
          },
        });
      }

      if (multipleImages != null && multipleImages.isNotEmpty) {
        for (final img in multipleImages) {
          parts.add({
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': base64Encode(img),
            },
          });
        }
      }

      final directText = await _callGeminiDirect(parts: parts);
      if (directText != null && directText.isNotEmpty) {
        return directText;
      }
    }

    // 2. Primary & Secure Route: FitLens Server-Side AI Proxy
    try {
      final url = Uri.parse('${ApiConstants.backendBaseUrl}/api/ai/generate');
      final payload = <String, dynamic>{
        'prompt': prompt,
        if (imageBytes != null) 'imageBase64': base64Encode(imageBytes),
        if (multipleImages != null && multipleImages.isNotEmpty)
          'multipleImages': multipleImages.map((b) => base64Encode(b)).toList(),
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              ...ApiConstants.defaultHeaders,
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final responseText = jsonResponse['text'] as String?;

        if (responseText != null && responseText.isNotEmpty) {
          if (useCache && cacheKey != null) {
            try {
              await firestore.collection('ai_cache').doc(cacheKey).set({
                'response': responseText,
                'timestamp': FieldValue.serverTimestamp(),
              });
            } catch (_) {}
          }
          return responseText;
        }
      }
    } catch (_) {}

    throw Exception('Unable to generate AI content. Please check your internet connection.');
  }

  /// Sends a multi-turn chat message to Gemini AI via secure backend proxy.
  Future<String?> generateChatContent({
    required List<Map<String, String>> history,
    required String message,
  }) async {
    // 1. Direct call if compile-time key provided
    if (_envApiKey.isNotEmpty) {
      final contents = <Map<String, dynamic>>[];
      for (final item in history) {
        final role = item['role'] == 'user' ? 'user' : 'model';
        final text = item['text'] ?? item['content'] ?? '';
        if (text.isNotEmpty) {
          contents.add({
            'role': role,
            'parts': [
              {'text': text}
            ],
          });
        }
      }

      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ],
      });

      final directResponse = await _callGeminiDirect(parts: [], contents: contents);
      if (directResponse != null && directResponse.isNotEmpty) {
        return directResponse;
      }
    }

    // 2. Primary & Secure Route: FitLens Server-Side AI Chat Proxy
    try {
      final url = Uri.parse('${ApiConstants.backendBaseUrl}/api/ai/chat');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              ...ApiConstants.defaultHeaders,
            },
            body: jsonEncode({
              'history': history,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final responseText = jsonResponse['text'] as String?;
        if (responseText != null && responseText.isNotEmpty) {
          return responseText;
        }
      }
    } catch (_) {}

    throw Exception('Unable to reach AI Chat Stylist. Please check your internet connection.');
  }

  /// Robustly extracts and decodes a JSON object from model responses.
  Map<String, dynamic> extractJson(String rawText) {
    try {
      String cleaned = rawText.trim();

      // Find first '{' and last '}'
      final startIndex = cleaned.indexOf('{');
      final endIndex = cleaned.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      } else {
        if (cleaned.startsWith('```')) {
          cleaned = cleaned
              .replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '')
              .replaceFirst(RegExp(r'\n?```$'), '')
              .trim();
        }
      }

      // Repair trailing commas before closing braces/brackets
      cleaned = cleaned.replaceAllMapped(RegExp(r',\s*([\}\]])'), (m) => m[1]!);

      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      throw Exception('Decoded JSON is not an object.');
    } catch (e) {
      throw Exception('Failed to decode JSON from AI response: $e\nRaw Response: $rawText');
    }
  }
}
