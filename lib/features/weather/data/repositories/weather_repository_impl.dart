import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<WeatherEntity> getLocalWeather(double lat, double lon) async {
    return await remoteDataSource.getLocalWeather(lat, lon);
  }

  @override
  Future<WeatherEntity> getWeatherByCity(String city) async {
    return await remoteDataSource.getWeatherByCity(city);
  }
}
