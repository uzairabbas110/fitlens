import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../payment/presentation/screens/checkout_sheet.dart';
import '../../../payment/presentation/widgets/payment_brand_logos.dart';

class PremiumPaywallSheet extends ConsumerStatefulWidget {
  const PremiumPaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumPaywallSheet(),
    );
  }

  @override
  ConsumerState<PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends ConsumerState<PremiumPaywallSheet> {
  String _selectedPlan = 'annual';

  Future<void> _handleUpgrade() async {
    Navigator.pop(context); // Close paywall sheet
    final paid = await CheckoutSheet.show(context, planKey: _selectedPlan);
    if (paid == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7E3B50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.stars, color: Color(0xFFC5A267)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🎉 Welcome to FitLens Premium! Unlimited AI Sizing unlocked.',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: const Color(0xFFC5A267).withValues(alpha: 0.4), width: 1.5),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Crown & Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7E3B50).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.5), width: 1.5),
                ),
                child: const Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 36),
              ),
              const SizedBox(height: 14),

              Text(
                'Free Demo Limit Reached',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'You have used your 3 free demo tries. Upgrade to FitLens VIP to unlock unlimited AI sizing, 10x30 capsule collections, trip packing, and event styling.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Feature bullets
              _buildFeatureItem(Icons.auto_awesome_mosaic, 'Unlimited 10x30 AI Capsule Wardrobe Generations', colorScheme),
              _buildFeatureItem(Icons.flight_takeoff, 'Unlimited AI Travel Packing & Itinerary Matching', colorScheme),
              _buildFeatureItem(Icons.celebration, 'Unlimited Haute Couture Event & Occasion Styling', colorScheme),
              _buildFeatureItem(Icons.straighten, 'Unlimited AI Body Sizing & Tailor Fit Predictions', colorScheme),

              const SizedBox(height: 20),

              // Plan selector
              Row(
                children: [
                  Expanded(
                    child: _buildPlanCard(
                      planKey: 'annual',
                      title: 'Annual VIP',
                      price: 'Rs. 2,899',
                      subtext: 'Rs. 241/mo (Save 50%)',
                      badge: 'SAVE 50%',
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPlanCard(
                      planKey: 'monthly',
                      title: 'Monthly VIP',
                      price: 'Rs. 1,499',
                      subtext: 'Billed monthly',
                      badge: null,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E3B50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, color: Color(0xFFC5A267), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pay with Easypaisa, JazzCash & Cards',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Payment Badges with authentic official logos
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  EasypaisaChip(),
                  JazzCashChip(),
                  VisaMastercardChip(),
                ],
              ),

              const SizedBox(height: 12),

              // View Full Details link
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/premium');
                },
                child: Text(
                  'Explore All FitLens Premium Features →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF7E3B50), size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String planKey,
    required String title,
    required String price,
    required String subtext,
    required String? badge,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedPlan == planKey;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = planKey),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF7E3B50).withValues(alpha: 0.08)
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF7E3B50) : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A267),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
