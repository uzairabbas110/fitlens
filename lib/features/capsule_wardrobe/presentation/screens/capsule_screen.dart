import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../sizing/presentation/widgets/premium_paywall_sheet.dart';
import '../providers/capsule_provider.dart';
import '../../data/models/capsule_model.dart';

class CapsuleScreen extends ConsumerStatefulWidget {
  const CapsuleScreen({super.key});

  @override
  ConsumerState<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends ConsumerState<CapsuleScreen> {
  String _selectedSeason = 'All Season';
  String _selectedVibe = 'Quiet Luxury & Minimalist';
  String _outfitFilter = 'All';

  final List<String> _seasons = ['All Season', 'Spring / Summer', 'Autumn / Winter'];
  final List<String> _vibes = [
    'Quiet Luxury & Minimalist',
    'Parisian Classic',
    'Old Money Aesthetic',
    'Modern Workwear & Sharp',
    'Casual Street Style',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final capsuleState = ref.read(capsuleProvider);
      final subState = ref.read(subscriptionProvider);
      if (capsuleState.capsule == null && !capsuleState.isLoading) {
        if (subState.canUseCapsule) {
          ref.read(subscriptionProvider.notifier).incrementCapsuleTries();
          ref.read(capsuleProvider.notifier).generateCapsule(
                season: _selectedSeason,
                vibe: _selectedVibe,
              );
        }
      }
    });
  }

  void _regenerate() {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canUseCapsule) {
      PremiumPaywallSheet.show(context);
      return;
    }

    ref.read(subscriptionProvider.notifier).incrementCapsuleTries();
    ref.read(capsuleProvider.notifier).generateCapsule(
          season: _selectedSeason,
          vibe: _selectedVibe,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subState = ref.watch(subscriptionProvider);
    final capsuleState = ref.watch(capsuleProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A267).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'VIP 10x30',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7E3B50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Capsule Wardrobe',
              style: GoogleFonts.montserratAlternates(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
            tooltip: 'Regenerate Capsule',
            onPressed: capsuleState.isLoading ? null : _regenerate,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FloatingFashionBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Free Demo Trial Banner (3 tries)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                child: _buildTrialStatusBanner(theme, colorScheme, subState),
              ),

              // Filter Controls (Season & Vibe Chips)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._seasons.map((season) {
                            final isSelected = _selectedSeason == season;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(season),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() => _selectedSeason = season);
                                    _regenerate();
                                  }
                                },
                                selectedColor: const Color(0xFF7E3B50),
                                labelStyle: TextStyle(
                                  fontSize: 11.5,
                                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _vibes.map((vibe) {
                          final isSelected = _selectedVibe == vibe;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(vibe),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  setState(() => _selectedVibe = vibe);
                                  _regenerate();
                                }
                              },
                              selectedColor: colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                              ),
                              backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: capsuleState.isLoading
                    ? _buildLoadingView(theme, colorScheme)
                    : capsuleState.error != null
                        ? _buildErrorView(capsuleState.error!, theme, colorScheme)
                        : capsuleState.capsule != null
                            ? _buildCapsuleContent(capsuleState.capsule!, theme, colorScheme)
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF7E3B50),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Assembling 10x30 Capsule...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecting 10 high-versatility pieces & calculating 30 mix-and-match formulas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_mosaic_outlined, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Generation Notice',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _regenerate,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleContent(CapsuleWardrobe capsule, ThemeData theme, ColorScheme colorScheme) {
    final filteredOutfits = _outfitFilter == 'All'
        ? capsule.outfitFormulas
        : capsule.outfitFormulas.where((o) => o.occasion.toLowerCase().contains(_outfitFilter.toLowerCase())).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      children: [
        // Palette Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D2930).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A267).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.palette_outlined, color: Color(0xFF7E3B50), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harmonious Color Palette',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      capsule.colorPaletteSummary,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 10 Core Pieces Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'The 10 Core Pieces',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${capsule.corePieces.length} Items',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal Core Pieces Carousel
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: capsule.corePieces.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final piece = capsule.corePieces[idx];
              return Container(
                width: 170,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${idx + 1}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7E3B50)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            piece.category,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colorScheme.outline),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      piece.name,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      'Color: ${piece.color}',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 28),

        // Outfit Formulas Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '30 Outfit Formulas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${filteredOutfits.length} generated',
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Occasion filter tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Work', 'Casual', 'Evening'].map((occ) {
              final isSelected = _outfitFilter == occ;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(occ == 'All' ? 'All Looks' : occ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _outfitFilter = occ);
                  },
                  selectedColor: const Color(0xFF7E3B50),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // List of Outfit Formulas
        ...filteredOutfits.map((outfit) => _buildOutfitCard(outfit, theme, colorScheme)),
      ],
    );
  }

  Widget _buildOutfitCard(CapsuleOutfit outfit, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D2930).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7E3B50), Color(0xFFC5A267)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${outfit.outfitNumber}',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          title: Text(
            outfit.title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: colorScheme.onSurface),
          ),
          subtitle: Text(
            outfit.occasion,
            style: TextStyle(fontSize: 11.5, color: const Color(0xFF7E3B50), fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pieces Used:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: outfit.itemNames.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.checkroom_outlined, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(item, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A267).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFC5A267)),
                      const SizedBox(width: 6),
                      Text(
                        'Styling Advice',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outfit.stylingTip,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialStatusBanner(ThemeData theme, ColorScheme colorScheme, SubscriptionState subState) {
    if (subState.isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7E3B50).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'FitLens VIP Active • Unlimited 10x30 Capsule Generations',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7E3B50)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A267),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('VIP', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final remaining = subState.remainingCapsuleTries;
    if (remaining > 0) {
      return GestureDetector(
        onTap: () => PremiumPaywallSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Free Demo Trial: $remaining of 3 tries remaining',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
              Text(
                'Upgrade VIP →',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      );
    }

    // 0 tries remaining
    return GestureDetector(
      onTap: () => PremiumPaywallSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7E3B50).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC5A267)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFC5A267), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Free Demo Limit Reached (3/3 Used)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7E3B50)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7E3B50),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('UPGRADE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
