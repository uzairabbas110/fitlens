import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../domain/entities/analysis_entity.dart';
import '../providers/analysis_provider.dart';
import '../widgets/analysis_result_card.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final Uint8List imageBytes;

  const AnalysisScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  late Uint8List _currentImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentImageBytes = widget.imageBytes;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisNotifierProvider.notifier).analyzeImage(_currentImageBytes);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
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
        ref.read(analysisNotifierProvider.notifier).analyzeImage(bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getMessage(e, 'Unable to select image. Please try again.'))),
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
                'Analyze Another Clothing Item',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: theme.colorScheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
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
    final analysisState = ref.watch(analysisNotifierProvider);
    final notifier = ref.read(analysisNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: 'Analyze Another Photo',
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
                        height: 200,
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
                                Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  child: analysisState.when(
                    loading: () => _buildLoading(context),
                    error: (error, stackTrace) =>
                        _buildError(context, error, notifier),
                    data: (entity) {
                      if (entity == null) {
                        return _buildLoading(context);
                      }
        
                      return _buildSuccess(
                        context,
                        entity,
                      );
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

  /// Loading UI.
  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing clothing...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Error UI.
  Widget _buildError(
      BuildContext context,
      Object error,
      AnalysisNotifier notifier,
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
              onPressed: () => notifier.analyzeImage(widget.imageBytes),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Success UI.
  Widget _buildSuccess(
      BuildContext context,
      AnalysisEntity entity,
      ) {
    final fields = <(IconData, String, String)>[
      (
      Icons.checkroom_outlined,
      'Clothing Type',
      entity.clothingType,
      ),
      (
      Icons.palette_outlined,
      'Color',
      entity.color,
      ),
      (
      Icons.texture_outlined,
      'Pattern',
      entity.pattern,
      ),
      (
      Icons.layers_outlined,
      'Material',
      entity.material,
      ),
      (
      Icons.wb_sunny_outlined,
      'Season',
      entity.season,
      ),
      (
      Icons.event_outlined,
      'Occasion',
      entity.occasion,
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
              final (icon, label, value) = fields[index];

              return AnalysisResultCard(
                icon: icon,
                title: label,
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
                label: const Text('Scan Another'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  context.push(
                    '/recommendation',
                    extra: {
                      'imageBytes': _currentImageBytes,
                      'analysis': entity,
                    },
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Recommend'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}