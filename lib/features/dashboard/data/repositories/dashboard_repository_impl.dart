import 'dart:typed_data';

import '../datasources/dashboard_remote_data_source.dart';
import '../../domain/entities/dashboard_result_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FitLensResultEntity> analyzeMatch({
    required Uint8List? userImageBytes,
    required Uint8List? clothingImageBytes,
    String? weatherContext,
  }) async {
    try {
      final model = await remoteDataSource.analyzeMatch(
        userImageBytes: userImageBytes,
        clothingImageBytes: clothingImageBytes,
        weatherContext: weatherContext,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to generate recommendation: $e');
    }
  }
}
