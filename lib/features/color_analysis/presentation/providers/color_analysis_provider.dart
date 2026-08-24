import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/color_analysis_remote_data_source.dart';
import '../../data/repositories/color_analysis_repository_impl.dart';
import '../../domain/entities/color_recommendation_entity.dart';
import '../../domain/repositories/color_analysis_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

final colorAnalysisRemoteDataSourceProvider = Provider<ColorAnalysisRemoteDataSource>((ref) {
  return const ColorAnalysisRemoteDataSourceImpl();
});

final colorAnalysisRepositoryProvider = Provider<ColorAnalysisRepository>((ref) {
  return ColorAnalysisRepositoryImpl(
    remoteDataSource: ref.watch(colorAnalysisRemoteDataSourceProvider),
  );
});

class ColorAnalysisNotifier extends AsyncNotifier<ColorRecommendationEntity?> {
  @override
  Future<ColorRecommendationEntity?> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    if (user != null) {
      final repository = ref.read(colorAnalysisRepositoryProvider);
      return await repository.getSavedColorAnalysis(user.uid);
    }
    return null;
  }

  Future<void> analyzePhoto(Uint8List imageBytes) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(colorAnalysisRepositoryProvider);
      final result = await repository.analyzeSkinTone(imageBytes);
      
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        await repository.saveColorAnalysis(user.uid, result);
      }
      return result;
    });
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final colorAnalysisProvider =
    AsyncNotifierProvider<ColorAnalysisNotifier, ColorRecommendationEntity?>(
  ColorAnalysisNotifier.new,
);
