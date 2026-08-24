import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/generate_dashboard_result_usecase.dart';
import '../../domain/entities/dashboard_result_entity.dart';
import '../../../weather/presentation/providers/weather_provider.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return const DashboardRemoteDataSourceImpl();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
  );
});

final generateDashboardResultUseCaseProvider = Provider<GenerateDashboardResultUseCase>((ref) {
  return GenerateDashboardResultUseCase(
    ref.watch(dashboardRepositoryProvider),
  );
});

class DashboardNotifier extends AsyncNotifier<FitLensResultEntity?> {
  late GenerateDashboardResultUseCase _useCase;

  @override
  Future<FitLensResultEntity?> build() async {
    _useCase = ref.read(generateDashboardResultUseCaseProvider);
    return null;
  }

  Future<void> analyze({
    required Uint8List? userImageBytes,
    required Uint8List? clothingImageBytes,
  }) async {
    state = const AsyncLoading();
    
    // Fetch weather context if available
    String? weatherContext;
    final weatherState = ref.read(weatherProvider);
    if (weatherState.hasValue && weatherState.value != null) {
      final w = weatherState.value!;
      weatherContext = "Location: ${w.city}, Temp: ${w.temperature}°C, Condition: ${w.condition}";
    }

    state = await AsyncValue.guard(() async {
      return _useCase(
        userImageBytes: userImageBytes,
        clothingImageBytes: clothingImageBytes,
        weatherContext: weatherContext,
      );
    });
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, FitLensResultEntity?>(
  DashboardNotifier.new,
);
