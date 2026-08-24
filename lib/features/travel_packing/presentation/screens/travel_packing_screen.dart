import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../sizing/presentation/widgets/premium_paywall_sheet.dart';
import '../providers/travel_packing_provider.dart';
import '../../data/models/travel_packing_model.dart';

class TravelPackingScreen extends ConsumerStatefulWidget {
  const TravelPackingScreen({super.key});

  @override
  ConsumerState<TravelPackingScreen> createState() => _TravelPackingScreenState();
}

class _TravelPackingScreenState extends ConsumerState<TravelPackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _destinationController = TextEditingController();
  int _durationDays = 4;
  String _selectedVibe = 'City & Culture';
  String _selectedGender = 'Women';
  final _activitiesController = TextEditingController();

  final List<String> _genderOptions = [
    'Women',
    'Men',
    'Unisex',
  ];

  final List<String> _tripTypes = [
    'City & Culture',
    'Beach & Resort',
    'Business & Conference',
    'Romantic Getaway',
    'Winter / Alpine',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(travelPackingProvider);
      final subState = ref.read(subscriptionProvider);
      if (state.tripPlan == null && !state.isLoading) {
        if (subState.canUseTravelPacking) {
          _generatePlan();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _destinationController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  void _generatePlan() {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canUseTravelPacking) {
      PremiumPaywallSheet.show(context);
      return;
    }

    ref.read(subscriptionProvider.notifier).incrementTravelPackingTries();
    ref.read(travelPackingProvider.notifier).generateTripPlan(
          destination: _destinationController.text.trim().isEmpty ? 'Paris' : _destinationController.text.trim(),
          durationDays: _durationDays,
          tripType: _selectedVibe,
          genderPreference: _selectedGender,
          activities: _activitiesController.text.trim(),
        );
  }

  void _showCustomizeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customize Your Trip',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      prefixIcon: const Icon(Icons.flight_takeoff),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Trip Length:', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _durationDays > 1
                                ? () {
                                    setState(() => _durationDays--);
                                    setModalState(() {});
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_durationDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            onPressed: _durationDays < 14
                                ? () {
                                    setState(() => _durationDays++);
                                    setModalState(() {});
                                  }
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Style & Gender Preference:', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _genderOptions.map((gender) {
                      final isSelected = _selectedGender == gender;
                      final icon = gender == 'Women'
                          ? Icons.female
                          : gender == 'Men'
                              ? Icons.male
                              : Icons.all_inclusive_rounded;
                      return ChoiceChip(
                        avatar: Icon(
                          icon,
                          size: 16,
                          color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                        ),
                        label: Text(gender),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedGender = gender);
                            setModalState(() {});
                          }
                        },
                        selectedColor: const Color(0xFF7E3B50),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('Trip Vibe:', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tripTypes.map((type) {
                      final isSelected = _selectedVibe == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedVibe = type);
                            setModalState(() {});
                          }
                        },
                        selectedColor: const Color(0xFF7E3B50),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _generatePlan();
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text('Generate Packing Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E3B50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final packingState = ref.watch(travelPackingProvider);

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
                    'VIP SUITE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7E3B50)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Travel Packing',
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
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Customize Trip',
            onPressed: _showCustomizeDialog,
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

              // Destination & Tab Navigation
              if (packingState.tripPlan != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D2930), Color(0xFF7E3B50)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D2930).withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Color(0xFFC5A267), size: 20),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      packingState.tripPlan!.destination,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${packingState.tripPlan!.durationDays} Days • ${packingState.tripPlan!.genderPreference != null ? "${packingState.tripPlan!.genderPreference} • " : ""}${packingState.tripPlan!.tripType}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                packingState.tripPlan!.climateSummary,
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.luggage_outlined, color: Color(0xFFC5A267), size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                packingState.tripPlan!.luggageAdvice,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFC5A267)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF7E3B50),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(icon: Icon(Icons.checklist_rtl, size: 18), text: 'Packing Checklist'),
                      Tab(icon: Icon(Icons.calendar_today, size: 18), text: 'Daily Outfits'),
                    ],
                  ),
                ),
              ],

              // Body Content
              Expanded(
                child: packingState.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF7E3B50)),
                            const SizedBox(height: 16),
                            Text('Generating Smart Travel Wardrobe...', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : packingState.error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flight_land, color: colorScheme.error, size: 48),
                                  const SizedBox(height: 12),
                                  Text(packingState.error!, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(onPressed: _generatePlan, child: const Text('Try Again')),
                                ],
                              ),
                            ),
                          )
                        : packingState.tripPlan != null
                            ? TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildChecklistTab(packingState.tripPlan!, colorScheme),
                                  _buildDailyOutfitsTab(packingState.tripPlan!, theme, colorScheme),
                                ],
                              )
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistTab(TravelTripPlan plan, ColorScheme colorScheme) {
    final total = plan.checklist.length;
    final checked = plan.checklist.where((c) => c.isChecked).length;
    final progress = total > 0 ? checked / total : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        // Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Packed Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface)),
                  Text('$checked of $total packed (${(progress * 100).toInt()}%)', style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: const Color(0xFF7E3B50),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Items List
        ...plan.checklist.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isChecked ? colorScheme.primary.withValues(alpha: 0.5) : colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: CheckboxListTile(
              value: item.isChecked,
              activeColor: const Color(0xFF7E3B50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(
                item.name,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  color: item.isChecked ? colorScheme.outline : colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${item.category} • Qty: ${item.quantity}',
                style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
              ),
              onChanged: (_) {
                ref.read(travelPackingProvider.notifier).toggleItem(item.id);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDailyOutfitsTab(TravelTripPlan plan, ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: plan.dayByDayOutfits.length,
      itemBuilder: (context, idx) {
        final day = plan.dayByDayOutfits[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D2930).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      day.dayTitle,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A267).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      day.temperatureExpected,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7E3B50)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Activity: ${day.activity}',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: day.outfitPieces.map((piece) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(piece, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: colorScheme.onSecondaryContainer)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.nightlight_round, size: 14, color: Color(0xFF7E3B50)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      day.eveningLayerTip,
                      style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                'FitLens VIP Active • Unlimited AI Trip Packing',
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

    final remaining = subState.remainingTravelPackingTries;
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
