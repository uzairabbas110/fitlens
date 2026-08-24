import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/weather_entity.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import '../../data/repositories/weather_repository_impl.dart';

class WeatherNotifier extends AsyncNotifier<WeatherEntity> {
  late WeatherRepositoryImpl _repository;

  @override
  Future<WeatherEntity> build() async {
    final dataSource = WeatherRemoteDataSourceImpl();
    _repository = WeatherRepositoryImpl(dataSource);
    return _fetchByGeolocation();
  }

  Future<WeatherEntity> _fetchByGeolocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please enable them in your browser/device settings.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    } 

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      // Fallback to a default city if Web Geolocation hangs or fails
      return await _repository.getWeatherByCity('New York');
    }

    return await _repository.getLocalWeather(position.latitude, position.longitude);
  }

  Future<void> setCity(String city) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getWeatherByCity(city));
  }

  Future<void> refreshLocation() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchByGeolocation());
  }
}

final weatherProvider = AsyncNotifierProvider<WeatherNotifier, WeatherEntity>(() {
  return WeatherNotifier();
});
