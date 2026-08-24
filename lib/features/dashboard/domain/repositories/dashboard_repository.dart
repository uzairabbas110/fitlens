import 'dart:typed_data';
import '../entities/dashboard_result_entity.dart';

abstract class DashboardRepository {
  Future<FitLensResultEntity> analyzeMatch({
    required Uint8List? userImageBytes,
    required Uint8List? clothingImageBytes,
    String? weatherContext,
  });
}
