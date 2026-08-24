import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getLocalWeather(double lat, double lon);
  Future<WeatherEntity> getWeatherByCity(String city);
}
