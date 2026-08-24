import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../domain/entities/dashboard_result_entity.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Uint8List? userImageBytes;
  final Uint8List? clothingImageBytes;
  final String feature;

  const DashboardScreen({
    super.key,
    required this.userImageBytes,
    required this.clothingImageBytes,
    required this.feature,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Uint8List? _currentUserImageBytes;
  late Uint8List? _currentClothingImageBytes;

  @override
  void initState() {
    super.initState();
    _currentUserImageBytes = widget.userImageBytes;
    _currentClothingImageBytes = widget.clothingImageBytes;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  void _runAnalysis() {
    ref.read(dashboardProvider.notifier).analyze(
      userImageBytes: _currentUserImageBytes,
      clothingImageBytes: _currentClothingImageBytes,
    );
  }

  Future<void> _pickImageAndAnalyze({
    required bool isClothing,
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (isClothing) {
            _currentClothingImageBytes = bytes;
          } else {
            _currentUserImageBytes = bytes;
          }
        });
        _runAnalysis();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getMessage(e, 'Unable to load image. Please try again.'))),
        );
      }
    }
  }

  void _showReanalyzeOptions(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Analyze Another Image',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Pick or capture a new photo to run instant analysis',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Option 1: New Clothing Item
              Text('Clothing Item', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImageAndAnalyze(isClothing: true, source: ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImageAndAnalyze(isClothing: true, source: ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              // Option 2: User Photo
              Text('Your Photo (Body / Skin Tone)', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImageAndAnalyze(isClothing: false, source: ImageSource.camera);
                      },
                      icon: const Icon(Icons.person_outline),
                      label: const Text('New Selfie'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImageAndAnalyze(isClothing: false, source: ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_outlined),
                      label: const Text('User Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<FitLensResultEntity?>>(
      dashboardProvider,
      (previous, next) {
        if (next is AsyncData && next.value != null && previous?.value == null) {
          ref.read(historyNotifierProvider.notifier).saveDashboardResult(
            result: next.value!,
            feature: widget.feature,
            userImagePath: null,
            clothingImagePath: null,
          );
        }
      },
    );

    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLens Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: 'Analyze Another Photo',
            onPressed: () => _showReanalyzeOptions(context),
          ),
        ],
      ),
      body: FloatingFashionBackground(
        child: state.when(
        data: (result) {
          if (result == null) {
            return _buildLoading();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAnalyzedPhotosBanner(),
                const SizedBox(height: 16),
                if (widget.feature == 'buy' || widget.feature == 'all') ...[
                  _buildHeader(context, result.buyAdvice),
                  const SizedBox(height: 16),
                ],
                _buildScoreCards(result),
                const SizedBox(height: 16),
                _buildAnalysisDetails(context, result),
                const SizedBox(height: 24),
                
                // In-screen re-analysis and navigation action buttons
                FilledButton.icon(
                  onPressed: () => _showReanalyzeOptions(context),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Analyze Another Outfit / Photo'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Home'),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoading(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Analysis failed:\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.read(dashboardProvider.notifier).analyze(
                      userImageBytes: widget.userImageBytes,
                      clothingImageBytes: widget.clothingImageBytes,
                    );
                  },
                  child: const Text('Retry Analysis'),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Analyzing your body and clothing...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text(
            'Evaluating fabric, proportions, and color harmony',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String buyAdvice) {
    Color getAdviceColor() {
      final lowercase = buyAdvice.toLowerCase();
      if (lowercase.contains('highly')) return Colors.green;
      if (lowercase.contains('recommend')) return Colors.lightGreen;
      if (lowercase.contains('consider')) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getAdviceColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getAdviceColor().withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Text('Final Recommendation', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            buyAdvice.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: getAdviceColor(),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCards(FitLensResultEntity result) {
    List<Widget> cards = [];

    if (widget.feature == 'size' || widget.feature == 'all' || widget.feature == 'buy') {
      cards.add(Expanded(child: _buildScoreCard('Size Match', result.sizeMatchScore, Icons.straighten)));
    }
    if (widget.feature == 'skin_tone' || widget.feature == 'all' || widget.feature == 'buy') {
      cards.add(Expanded(child: _buildScoreCard('Color Match', result.colorMatchScore, Icons.color_lens)));
    }
    if (widget.feature == 'quality' || widget.feature == 'all' || widget.feature == 'buy') {
      cards.add(Expanded(child: _buildScoreCard('Quality', result.qualityScore, Icons.high_quality)));
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    // Insert spacing between cards
    List<Widget> spacedCards = [];
    for (int i = 0; i < cards.length; i++) {
      spacedCards.add(cards[i]);
      if (i < cards.length - 1) {
        spacedCards.add(const SizedBox(width: 8));
      }
    }

    return Row(children: spacedCards);
  }

  Widget _buildScoreCard(String title, int score, IconData icon) {
    final Color color;
    if (score >= 80) {
      color = const Color(0xFF2E7D32);
    } else if (score >= 60) {
      color = const Color(0xFFFB8C00);
    } else {
      color = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$score%',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisDetails(BuildContext context, FitLensResultEntity result) {
    List<Widget> listItems = [];
    final feature = widget.feature;

    if (feature == 'skin_tone' || feature == 'all' || feature == 'buy') {
      listItems.add(ListTile(
        title: const Text('Skin Tone'),
        subtitle: Text(result.skinTone),
        leading: const Icon(Icons.face),
      ));
    }
    
    if (feature == 'size' || feature == 'all' || feature == 'buy') {
      listItems.add(ListTile(
        title: const Text('Estimated Size'),
        subtitle: Text(result.estimatedSize),
        leading: const Icon(Icons.person),
      ));
      listItems.add(ListTile(
        title: const Text('Recommended Clothing Size'),
        subtitle: Text(result.recommendedSize),
        leading: const Icon(Icons.checkroom),
      ));
    }

    if (feature == 'quality' || feature == 'all' || feature == 'buy') {
      listItems.add(ListTile(
        title: const Text('Fabric Quality'),
        subtitle: Text(result.clothingQuality),
        leading: const Icon(Icons.texture),
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analysis Details', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...listItems,
            const Divider(),
            const Text('Reasoning', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(result.reasoning),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzedPhotosBanner() {
    final hasUser = _currentUserImageBytes != null;
    final hasClothing = _currentClothingImageBytes != null;

    if (!hasUser && !hasClothing) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (hasUser) ...[
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _currentUserImageBytes!,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _pickImageAndAnalyze(isClothing: false, source: ImageSource.camera),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasUser && hasClothing) const SizedBox(width: 10),
          if (hasClothing) ...[
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _currentClothingImageBytes!,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _pickImageAndAnalyze(isClothing: true, source: ImageSource.camera),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Outfit', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

