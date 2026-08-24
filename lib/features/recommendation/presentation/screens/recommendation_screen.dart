import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../analysis/domain/entities/analysis_entity.dart';
import '../../../analysis/presentation/providers/analysis_provider.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/recommendation_result_card.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  final Uint8List imageBytes;
  final AnalysisEntity analysis;

  const RecommendationScreen({
    super.key,
    required this.imageBytes,
    required this.analysis,
  });

  @override
  ConsumerState<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  late AnalysisEntity _currentAnalysis;
  late Uint8List _currentImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentAnalysis = widget.analysis;
    _currentImageBytes = widget.imageBytes;
    Future.microtask(() => _runRecommendation());
  }

  void _runRecommendation() {
    ref.read(recommendationNotifierProvider.notifier).generateRecommendation(
      imageBytes: _currentImageBytes,
      analysis: _currentAnalysis,
    );
  }

  Future<void> _pickNewImageAndRecommend(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _currentImageBytes = bytes;
        });

        // Analyze new clothing item and then generate recommendations
        final useCase = ref.read(analyzeImageUseCaseProvider);
        final newAnalysis = await useCase(bytes);
        
        setState(() {
          _currentAnalysis = newAnalysis;
        });

        _runRecommendation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getMessage(e, 'Unable to process image. Please try again.'))),
        );
      }
    }
  }

  void _showPickerModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Recommendations for Another Item',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickNewImageAndRecommend(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: theme.colorScheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickNewImageAndRecommend(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationState = ref.watch(recommendationNotifierProvider);
    final notifier = ref.read(recommendationNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Recommendation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: 'Pick Another Item',
            onPressed: () => _showPickerModal(context),
          ),
        ],
      ),
      body: FloatingFashionBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _currentImageBytes,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showPickerModal(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text('Change Item', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: recommendationState.when(
                    loading: () => _buildLoading(context),
                    error: (error, stackTrace) =>
                        _buildError(context, error, notifier),
                    data: (entity) {
                      if (entity == null) {
                        return _buildLoading(context);
                      }
                      return _buildSuccess(context, entity);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders the loading state: a spinner with a status message.
  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Generating outfit recommendations...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Renders the error state: an error icon, message, and retry button.
  Widget _buildError(
      BuildContext context,
      Object error,
      RecommendationNotifier notifier,
      ) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => notifier.generateRecommendation(
                imageBytes: _currentImageBytes,
                analysis: _currentAnalysis,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the success state: a list of RecommendationResultCard
  /// widgets, one per field of the recommendation result.
  Widget _buildSuccess(
      BuildContext context,
      RecommendationEntity entity,
      ) {
    final fields = <(IconData, String, String)>[
      (
      Icons.checkroom_outlined,
      'Recommended Top',
      entity.recommendedTop,
      ),
      (
      Icons.dry_cleaning_outlined,
      'Recommended Bottom',
      entity.recommendedBottom,
      ),
      (
      Icons.hiking_outlined,
      'Recommended Footwear',
      entity.recommendedFootwear,
      ),
      (
      Icons.watch_outlined,
      'Recommended Accessory',
      entity.recommendedAccessory,
      ),
      (
      Icons.style_outlined,
      'Style Description',
      entity.styleDescription,
      ),
      (
      Icons.palette_outlined,
      'Color Harmony',
      entity.colorHarmony,
      ),
      (
      Icons.lightbulb_outline,
      'Reason',
      entity.reason,
      ),
      (
      Icons.percent_outlined,
      'Confidence',
      '${entity.confidencePercentage.toStringAsFixed(1)}%',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: fields.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final (icon, title, value) = fields[index];

              return RecommendationResultCard(
                icon: icon,
                title: title,
                value: value,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showPickerModal(context),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('New Item'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}