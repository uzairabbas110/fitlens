import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../sizing/presentation/widgets/premium_paywall_sheet.dart';
import '../providers/event_stylist_provider.dart';
import '../../data/models/event_styling_model.dart';

class EventStylistScreen extends ConsumerStatefulWidget {
  const EventStylistScreen({super.key});

  @override
  ConsumerState<EventStylistScreen> createState() => _EventStylistScreenState();
}

class _EventStylistScreenState extends ConsumerState<EventStylistScreen> {
  final _eventController = TextEditingController();
  String _selectedDressCode = 'Smart Casual';
  final _venueController = TextEditingController();

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Romantic Date Night', 'code': 'Smart Casual', 'icon': Icons.favorite_border},
    {'name': 'Job Interview', 'code': 'Business Professional', 'icon': Icons.work_outline},
    {'name': 'Wedding Guest', 'code': 'Cocktail / Semi-Formal', 'icon': Icons.celebration_outlined},
    {'name': 'Black Tie Gala', 'code': 'Black Tie', 'icon': Icons.star_border},
    {'name': 'Chic Sunday Brunch', 'code': 'Casual Chic', 'icon': Icons.local_cafe_outlined},
    {'name': 'Art Gallery Opening', 'code': 'Creative Avant-Garde', 'icon': Icons.palette_outlined},
  ];

  final List<String> _dressCodes = [
    'Smart Casual',
    'Casual Chic',
    'Business Professional',
    'Cocktail / Semi-Formal',
    'Black Tie',
    'Creative Avant-Garde',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(eventStylistProvider);
      final subState = ref.read(subscriptionProvider);
      if (state.result == null && !state.isLoading) {
        if (subState.canUseEventStylist) {
          _generateStyling();
        }
      }
    });
  }

  @override
  void dispose() {
    _eventController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  void _generateStyling() {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canUseEventStylist) {
      PremiumPaywallSheet.show(context);
      return;
    }

    ref.read(subscriptionProvider.notifier).incrementEventStylistTries();
    ref.read(eventStylistProvider.notifier).generateEventOutfit(
          eventName: _eventController.text.trim().isEmpty ? 'Special Event' : _eventController.text.trim(),
          dressCode: _selectedDressCode,
          venueOrVibe: _venueController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stylistState = ref.watch(eventStylistProvider);

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
                    'VIP OCCASION',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7E3B50)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Event Stylist',
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
            tooltip: 'Restyle',
            onPressed: stylistState.isLoading ? null : _generateStyling,
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
                child: _buildTrialStatusBanner(theme, colorScheme, ref.watch(subscriptionProvider)),
              ),

              // Event Preset Horizontal Selector
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _presets.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final preset = _presets[idx];
                    final isSelected = _eventController.text == preset['name'];
                    return ChoiceChip(
                      avatar: Icon(preset['icon'] as IconData, size: 14, color: isSelected ? Colors.white : colorScheme.primary),
                      label: Text(preset['name'] as String),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _eventController.text = preset['name'] as String;
                            _selectedDressCode = preset['code'] as String;
                          });
                          _generateStyling();
                        }
                      },
                      selectedColor: const Color(0xFF7E3B50),
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    );
                  },
                ),
              ),

              const SizedBox(height: 6),

              // Dress Code Filter Row
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _dressCodes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final code = _dressCodes[idx];
                    final isSelected = _selectedDressCode == code;
                    return FilterChip(
                      label: Text(code),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedDressCode = code);
                          _generateStyling();
                        }
                      },
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Main Body
              Expanded(
                child: stylistState.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(color: Color(0xFF7E3B50)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Crafting Haute Couture Event Look...',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                            const SizedBox(height: 6),
                            Text('Selecting silhouettes, color harmony, jewelry & scent tips', style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : stylistState.error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                                  const SizedBox(height: 12),
                                  Text(stylistState.error!, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(onPressed: _generateStyling, child: const Text('Try Again')),
                                ],
                              ),
                            ),
                          )
                        : stylistState.result != null
                            ? _buildStylingResult(stylistState.result!, theme, colorScheme)
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStylingResult(EventStylingResult result, ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        // Headline Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3D2930), Color(0xFF7E3B50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7E3B50).withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A267).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      result.dressCode.toUpperCase(),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFFC5A267)),
                    ),
                  ),
                  Text(
                    result.eventName,
                    style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                result.styleHeadline,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                result.colorHarmonyAnalysis,
                style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Head-to-Toe Outfit Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),

        // Pieces Cards
        ...result.outfitBreakdown.map((piece) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D2930).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E3B50).withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.checkroom_outlined, color: const Color(0xFF7E3B50), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            piece.category,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(piece.color, style: TextStyle(fontSize: 10.5, color: colorScheme.onSurfaceVariant)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        piece.itemName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        piece.details,
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        // Accessories & Finishing Touches
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFC5A267), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Jewelry & Finishing Accessories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.accessoriesAndJewelry.map((acc) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Text(acc, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.face_retouching_natural, size: 16, color: Color(0xFF7E3B50)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grooming & Fragrance Scent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurface)),
                        const SizedBox(height: 2),
                        Text(result.groomingAndFragranceTip, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology_outlined, size: 16, color: Color(0xFFC5A267)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Executive Presence & Posture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurface)),
                        const SizedBox(height: 2),
                        Text(result.confidenceAndPostureTip, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
                'FitLens VIP Active • Unlimited Event Styling',
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

    final remaining = subState.remainingEventStylistTries;
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
