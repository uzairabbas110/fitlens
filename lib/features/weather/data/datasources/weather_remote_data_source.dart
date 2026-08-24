import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getLocalWeather(double lat, double lon);
  Future<WeatherModel> getWeatherByCity(String city);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  String _decodeWmoCode(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  Future<String> _getAiSuggestion(double temp, String condition, String city) async {
    try {
      final prompt =
          'You are a fashion assistant. It is ${temp.round()}°C and $condition in $city. Give a single, short sentence of clothing advice for this weather.';
      final suggestion = await GeminiService().generateContent(prompt: prompt);
      if (suggestion != null && suggestion.trim().isNotEmpty) {
        return suggestion.replaceAll('\n', ' ').trim();
      }
    } catch (_) {}
    return 'Dress comfortably for $condition conditions at ${temp.round()}°C.';
  }

  @override
  Future<WeatherModel> getLocalWeather(double lat, double lon) async {
    // 1. Direct Open-Meteo High-Accuracy API (Free, Global, HTTPS, No Key Needed)
    try {
      final openMeteoUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      );
      final res = await http.get(openMeteoUrl).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>?;
        if (current != null) {
          final temp = (current['temperature_2m'] as num).toDouble();
          final code = (current['weather_code'] as num?)?.toInt() ?? 0;
          final condition = _decodeWmoCode(code);
          final suggestion = await _getAiSuggestion(temp, condition, 'Your Location');
          return WeatherModel(
            temperature: temp,
            condition: condition,
            city: 'Your Location',
            suggestion: suggestion,
          );
        }
      }
    } catch (_) {}

    // 2. Secure Server-Side Weather Proxy (Key is stored safely in server .env)
    try {
      final url = Uri.parse('${ApiConstants.backendBaseUrl}/api/weather/current?lat=$lat&lon=$lon');
      final response = await http.get(url, headers: ApiConstants.defaultHeaders).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final data = (jsonResponse['data'] as Map<String, dynamic>?) ?? jsonResponse;
        final suggestion = data['ai_suggestion'] as String? ?? 'Dress comfortably for the weather.';
        return WeatherModel.fromJson(data, suggestion);
      }
    } catch (_) {}

    // Default graceful fallback
    return WeatherModel(
      temperature: 22.0,
      condition: 'Clear',
      city: 'Local Area',
      suggestion: 'Dress comfortably for mild and clear weather.',
    );
  }

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
    // 1. Direct Open-Meteo Geocoding + Weather API
    try {
      final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
      );
      final geoRes = await http.get(geoUrl).timeout(const Duration(seconds: 6));
      if (geoRes.statusCode == 200) {
        final geoData = jsonDecode(geoRes.body) as Map<String, dynamic>;
        final results = geoData['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final lat = (first['latitude'] as num).toDouble();
          final lon = (first['longitude'] as num).toDouble();
          final cityName = first['name'] as String? ?? city;

          final weatherUrl = Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code',
          );
          final weatherRes = await http.get(weatherUrl).timeout(const Duration(seconds: 6));
          if (weatherRes.statusCode == 200) {
            final weatherData = jsonDecode(weatherRes.body) as Map<String, dynamic>;
            final current = weatherData['current'] as Map<String, dynamic>?;
            if (current != null) {
              final temp = (current['temperature_2m'] as num).toDouble();
              final code = (current['weather_code'] as num?)?.toInt() ?? 0;
              final condition = _decodeWmoCode(code);
              final suggestion = await _getAiSuggestion(temp, condition, cityName);
              return WeatherModel(
                temperature: temp,
                condition: condition,
                city: cityName,
                suggestion: suggestion,
              );
            }
          }
        }
      }
    } catch (_) {}

    // 2. Secure Server-Side Weather Proxy (Key is stored safely in server .env)
    try {
      final url = Uri.parse('${ApiConstants.backendBaseUrl}/api/weather/current?city=${Uri.encodeComponent(city)}');
      final response = await http.get(url, headers: ApiConstants.defaultHeaders).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final data = (jsonResponse['data'] as Map<String, dynamic>?) ?? jsonResponse;
        final suggestion = data['ai_suggestion'] as String? ?? 'Dress comfortably for the weather.';
        return WeatherModel.fromJson(data, suggestion);
      }
    } catch (_) {}

    return WeatherModel(
      temperature: 22.0,
      condition: 'Clear',
      city: city,
      suggestion: 'Dress comfortably for the weather.',
    );
  }
}
