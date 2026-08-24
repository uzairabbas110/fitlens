import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../../core/widgets/fitlens_logo.dart';
import '../providers/measurement_provider.dart';
import '../widgets/premium_paywall_sheet.dart';

class SizingScreen extends ConsumerStatefulWidget {
  const SizingScreen({super.key});

  @override
  ConsumerState<SizingScreen> createState() => _SizingScreenState();
}

class _SizingScreenState extends ConsumerState<SizingScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  bool _saveToProfile = true;
  bool _showErrorDetails = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (xFile != null) {
        final bytes = await xFile.readAsBytes();
        if (mounted) {
          ref.read(measurementProvider.notifier).analyzeBodyProportions(bytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getMessage(e, 'Could not load image.'))),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canUseSizing) {
      PremiumPaywallSheet.show(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Photo Source",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "For best results, upload a full-body standing photo with good lighting.",
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                  ),
                  title: const Text("Take a Photo", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Use device camera"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndAnalyzeImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library, color: theme.colorScheme.secondary),
                  ),
                  title: const Text("Choose from Gallery", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Pick an existing full-body photo"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndAnalyzeImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _calculateFromManual() {
    final chest = double.tryParse(_chestController.text.trim());
    final waist = double.tryParse(_waistController.text.trim());
    final hips = double.tryParse(_hipsController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (chest == null && waist == null && hips == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least Chest or Waist measurements, or scan with a photo.')),
      );
      return;
    }

    ref.read(measurementProvider.notifier).calculateFromManualInputs(
      chestCm: chest,
      waistCm: waist,
      hipsCm: hips,
      heightCm: height,
      weightKg: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final measurementState = ref.watch(measurementProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FloatingFashionBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;
            final topInset = MediaQuery.paddingOf(context).top;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: isDesktop ? 100 : (topInset + 72),
                    bottom: 120,
                    left: isDesktop ? 32 : 24,
                    right: isDesktop ? 32 : 24,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Find Your Perfect Fit",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 32 : 28,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Let our AI stylist analyze your measurements for tailored clothing recommendations.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 896),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3D2930).withValues(alpha: 0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(isDesktop ? 32 : 24),
                            child: Flex(
                              direction: isDesktop ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isDesktop)
                                  Expanded(child: _buildLeftImage(theme))
                                else
                                  _buildLeftImage(theme),
                                
                                SizedBox(
                                  width: isDesktop ? 32 : 0,
                                  height: isDesktop ? 0 : 24,
                                ),
                                
                                if (isDesktop)
                                  Expanded(child: _buildRightContent(measurementState, theme))
                                else
                                  _buildRightContent(measurementState, theme),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: isDesktop ? _buildDesktopHeader(theme) : _buildMobileHeader(context, theme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftImage(ThemeData theme) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.85,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBj-XFjUrSXUG9kAzzXdWkzRr3s-aTc-7vryDD9_51u-8f1fc9UFozKXEIuRaAmeCIll1qbylXExBHEZIHC_lfQX3umCD5XWY69rCsU4LYp4oyfTbOE84qkC8fqTNtKzTiczpobJVr89oFxRm4Em23HnHqvEJGoywzAtjiDWjdgfeVdzCj6sWxLfk6Q6_JZy3x1x7a8k84iD3nQbpAqI9Q3PTuXbaCZrOUIY733lk-zqF35xJkq9z_h7w',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.multiply,
                  color: theme.colorScheme.surfaceContainerLow,
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 40,
            child: _buildTag("Chest", theme),
          ),
          Positioned(
            top: 145,
            right: 40,
            child: _buildTag("Waist", theme),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: _buildTag("Hips", theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightContent(AsyncValue measurementState, ThemeData theme) {
    return measurementState.when(
      data: (entity) {
        if (entity == null) {
          return _buildForm(theme);
        }
        return _buildResults(entity, theme);
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                "Scanning body proportions with AI...",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                "Estimating chest, waist, hips & brand fits",
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      error: (e, stack) => _buildErrorView(e, theme),
    );
  }

  Widget _buildErrorView(Object error, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.error, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "AI Analysis Notice",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "The AI measurement service experienced high demand or temporary network congestion. You can try uploading again, or enter your measurements manually.",
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Try Photo Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  ref.read(measurementProvider.notifier).resetState();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Enter Manual"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              setState(() {
                _showErrorDetails = !_showErrorDetails;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showErrorDetails ? "Hide technical details" : "View technical details",
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                ),
                Icon(
                  _showErrorDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
          if (_showErrorDetails) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                error.toString(),
                style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: theme.colorScheme.outline, fontSize: 14),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildInput("Height", "", "cm", _heightController, inputDecoration, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildInput("Weight", "", "kg", _weightController, inputDecoration, theme)),
          ],
        ),
        const SizedBox(height: 14),
        _buildInput("Chest", "", "cm/in", _chestController, inputDecoration, theme),
        const SizedBox(height: 14),
        _buildInput("Waist", "", "cm/in", _waistController, inputDecoration, theme),
        const SizedBox(height: 14),
        _buildInput("Hips", "", "cm/in", _hipsController, inputDecoration, theme),
        
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _saveToProfile, 
              onChanged: (v) {
                setState(() {
                  _saveToProfile = v ?? true;
                });
              },
              activeColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Text(
                "Save these measurements to my profile",
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              )
            )
          ],
        ),
        
        const SizedBox(height: 16),

        // Freemium Trial Status Banner
        _buildTrialStatusBanner(theme),

        const SizedBox(height: 14),

        // Primary action: AI Photo Scan (or Upgrade if 3 demo tries exhausted)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              final sub = ref.read(subscriptionProvider);
              if (!sub.canUseSizing) {
                PremiumPaywallSheet.show(context);
              } else {
                _showImageSourceDialog();
              }
            },
            icon: Icon(
              ref.watch(subscriptionProvider).canUseSizing ? Icons.auto_awesome : Icons.stars,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              _getScanButtonLabel(ref.watch(subscriptionProvider)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ref.watch(subscriptionProvider).canUseSizing
                  ? theme.colorScheme.primary
                  : const Color(0xFF7E3B50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary action: Calculate from manual inputs
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _calculateFromManual,
            icon: Icon(Icons.straighten, color: theme.colorScheme.primary, size: 18),
            label: Text(
              "Calculate from Numbers (Free)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  String _getScanButtonLabel(SubscriptionState sub) {
    if (sub.isPremium) return "Scan with AI Photo (VIP Unlimited)";
    if (sub.remainingSizingTries > 0) {
      return "Scan with AI Photo (${sub.remainingSizingTries}/3 Free)";
    }
    return "Unlock Unlimited Sizing • Upgrade";
  }

  Widget _buildTrialStatusBanner(ThemeData theme) {
    final subState = ref.watch(subscriptionProvider);
    final isPremium = subState.isPremium;
    final remaining = subState.remainingSizingTries;

    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF7E3B50).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FitLens VIP Active",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF7E3B50)),
                  ),
                  Text(
                    "Unlimited AI body sizing & tailor fit predictions.",
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A267),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "VIP",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (remaining > 0) {
      return GestureDetector(
        onTap: () => context.push('/premium'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Free Demo Trial: $remaining of 3 tries remaining",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                    Text(
                      "Upgrade to VIP anytime for unlimited precision scans.",
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.primary),
            ],
          ),
        ),
      );
    }

    // 0 tries remaining - Prompt to upgrade
    return GestureDetector(
      onTap: () => PremiumPaywallSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF7E3B50).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC5A267)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFC5A267), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Free Demo Limit Reached (3/3 Used)",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF7E3B50)),
                  ),
                  Text(
                    "Tap to upgrade to VIP & unlock unlimited AI sizing.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF7E3B50)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7E3B50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "UPGRADE",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    String label, 
    String hint, 
    String suffix, 
    TextEditingController controller,
    InputDecoration decoration, 
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        ),
        TextField(
          controller: controller,
          decoration: decoration.copyWith(
            hintText: hint,
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(suffix, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        )
      ],
    );
  }

  Widget _buildResults(dynamic entity, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Your Profile", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              tooltip: "Recalculate / Scan Again",
              icon: Icon(Icons.restart_alt, color: theme.colorScheme.primary),
              onPressed: () {
                ref.read(measurementProvider.notifier).resetState();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard("Estimated Size", entity.estimatedSize, Icons.checkroom, theme),
        const SizedBox(height: 12),
        _buildStatCard("Body Type", entity.bodyType, Icons.accessibility, theme),
        if (entity.chestInches != null || entity.waistInches != null || entity.hipsInches != null) ...[
          const SizedBox(height: 24),
          Text("Raw Measurements", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (entity.chestInches != null) Expanded(child: _buildMeasurementBadge("Chest", "${entity.chestInches} in", theme)),
              if (entity.chestInches != null && (entity.waistInches != null || entity.hipsInches != null)) const SizedBox(width: 8),
              if (entity.waistInches != null) Expanded(child: _buildMeasurementBadge("Waist", "${entity.waistInches} in", theme)),
              if (entity.waistInches != null && entity.hipsInches != null) const SizedBox(width: 8),
              if (entity.hipsInches != null) Expanded(child: _buildMeasurementBadge("Hips", "${entity.hipsInches} in", theme)),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text("Style Advice", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(entity.advice, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
        ),
        const SizedBox(height: 24),
        Text("Brand Recommendations", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...entity.brandRecommendations.map((brand) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 12),
              Text(brand.toString(), style: TextStyle(color: theme.colorScheme.onSurface)),
            ],
          ),
        )).toList(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text("Scan Photo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(measurementProvider.notifier).resetState();
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit Numbers"),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementBadge(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, ThemeData theme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: theme.colorScheme.surface.withValues(alpha: 0.85),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    const FitLensLogo(fontSize: 26),
                    IconButton(
                      icon: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(ThemeData theme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FitLensLogo(fontSize: 32),
              Row(
                children: [
                  Text("Home", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 24),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: theme.colorScheme.primary, width: 2))
                    ),
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("Profile", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.primary)),
                  ),
                  const SizedBox(width: 24),
                  Text("Inspire", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.notifications, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text("Sign In", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

