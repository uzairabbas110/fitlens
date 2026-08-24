import 'dart:typed_data';
import '../entities/dashboard_result_entity.dart';
import '../repositories/dashboard_repository.dart';

class GenerateDashboardResultUseCase {
  final DashboardRepository repository;

  const GenerateDashboardResultUseCase(this.repository);

  Future<FitLensResultEntity> call({
    required Uint8List? userImageBytes,
    required Uint8List? clothingImageBytes,
    String? weatherContext,
  }) {
    return repository.analyzeMatch(
      userImageBytes: userImageBytes,
      clothingImageBytes: clothingImageBytes,
      weatherContext: weatherContext,
    );
  }
}
