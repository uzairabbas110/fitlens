import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  WeatherModel({
    required super.temperature,
    required super.condition,
    required super.city,
    required super.suggestion,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String suggestion) {
    if (json.containsKey('current') && json.containsKey('location')) {
      // WeatherStack format
      return WeatherModel(
        temperature: (json['current']['temperature'] as num).toDouble(),
        condition: (json['current']['weather_descriptions'] as List).first as String,
        city: json['location']['name'] as String,
        suggestion: suggestion,
      );
    } else {
      // OpenWeatherMap format
      return WeatherModel(
        temperature: (json['main']['temp'] as num).toDouble(),
        condition: json['weather'][0]['main'] as String,
        city: json['name'] as String,
        suggestion: suggestion,
      );
    }
  }
}
