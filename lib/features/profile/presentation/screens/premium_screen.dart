import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../payment/presentation/screens/checkout_sheet.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  String _selectedPlan = 'annual';
  bool _isProcessing = false;

  Future<void> _handleUpgrade() async {
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
                  '🎉 Congratulations! You are now a FitLens VIP Premium member.',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    final isRestored = await ref.read(subscriptionProvider.notifier).restorePurchases();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (isRestored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your Premium subscription was restored successfully!')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active subscription found to restore.')),
      );
    }
  }

  Future<void> _handleCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFF7E3B50), size: 28),
            SizedBox(width: 10),
            Text('Cancel VIP Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel your FitLens VIP subscription?\n\nYou will immediately lose unlimited AI sizing scans, brand size predictions, and the 24/7 AI stylist concierge.',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep VIP Access', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);
      final success = await ref.read(subscriptionProvider.notifier).cancelSubscription();
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF3D2930),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your subscription has been canceled. You have returned to the free tier.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final isAlreadyPremium = subState.isPremium;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _handleRestore,
            child: Text(
              'Restore',
              style: TextStyle(
                color: const Color(0xFF7E3B50),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FloatingFashionBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              // Hero Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5A267).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'FITLENS VIP ACCESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFF7E3B50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Subtitle
              Text(
                'Elevate Your Style\nWith AI Precision',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Unlock unlimited body measurement scans, tailored brand size charts, and your 24/7 personal AI stylist concierge.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Current Status Banner if already Premium
              if (isAlreadyPremium) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E3B50).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC5A267)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFFC5A267), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You are a VIP Premium Member',
                              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                            Text(
                              'Plan: ${subState.premiumPlan?.toUpperCase() ?? "ACTIVE"} • Unlimited Access',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _isProcessing ? null : _handleCancelSubscription,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Features List
              _buildFeatureCard(
                icon: Icons.auto_awesome_mosaic,
                title: '10x30 Capsule Wardrobe Generator',
                description: 'Automatically craft 30 versatile mix-and-match outfits from 10 core closet items.',
                badge: 'NEW VIP',
                colorScheme: colorScheme,
                onTap: () => context.push(AppRoutes.capsule),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.flight_takeoff,
                title: 'AI Travel Packing & Itinerary Matcher',
                description: 'Destination climate & activity analysis for optimized luggage and day-by-day outfits.',
                badge: 'NEW VIP',
                colorScheme: colorScheme,
                onTap: () => context.push(AppRoutes.travelPacking),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.celebration,
                title: 'Event & Occasion Haute Couture Stylist',
                description: 'Curated head-to-toe styling, jewelry, grooming & presence tips for weddings & galas.',
                badge: 'NEW VIP',
                colorScheme: colorScheme,
                onTap: () => context.push(AppRoutes.eventStylist),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.straighten,
                title: 'Unlimited AI Body Sizing & Proportions',
                description: 'Scan your photo anytime with zero try limits for accurate tailor measurements.',
                colorScheme: colorScheme,
                onTap: () => context.push(AppRoutes.sizing),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.checkroom,
                title: 'Instant Brand Size Predictions',
                description: 'Know your exact fit for Zara, ASOS, Nike, H&M, Levi\'s, and international charts.',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.cloud_upload_outlined,
                title: 'Unlimited Smart Wardrobe Cloud Storage',
                description: 'Store unlimited clothing items and outfits in high-resolution Cloudflare R2 cloud.',
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 32),

              // Pricing Section (Only show if not already premium)
              if (!isAlreadyPremium) ...[
                Text(
                  'Choose Your Membership Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Annual Plan
                _buildPlanSelectionTile(
                  keyId: 'annual',
                  title: 'Annual VIP Membership',
                  price: 'Rs. 2,899',
                  interval: ' / year',
                  billedText: 'Rs. 241/mo equivalent • Save 50% vs Monthly (\$9.99/yr)',
                  badge: 'BEST VALUE • 50% OFF',
                  isSelected: _selectedPlan == 'annual',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 12),

                // Monthly Plan
                _buildPlanSelectionTile(
                  keyId: 'monthly',
                  title: 'Monthly Pass',
                  price: 'Rs. 1,499',
                  interval: ' / month',
                  billedText: 'Billed monthly • Cancel anytime (\$4.99/mo)',
                  badge: null,
                  isSelected: _selectedPlan == 'monthly',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 12),

                // Lifetime Plan
                _buildPlanSelectionTile(
                  keyId: 'lifetime',
                  title: 'Lifetime Perpetual VIP',
                  price: 'Rs. 9,999',
                  interval: ' one-time',
                  billedText: 'Pay once, enjoy unlimited FitLens AI forever (\$29.99)',
                  badge: 'VIP PERPETUAL',
                  isSelected: _selectedPlan == 'lifetime',
                  colorScheme: colorScheme,
                ),

                const SizedBox(height: 28),

                // Upgrade Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E3B50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stars, color: Color(0xFFC5A267), size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Upgrade with Easypaisa, JazzCash & Cards',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                // Payment Gateways Supported Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPaymentBadge('🟢 Easypaisa'),
                    const SizedBox(width: 8),
                    _buildPaymentBadge('🔴 JazzCash'),
                    const SizedBox(width: 8),
                    _buildPaymentBadge('💳 Visa / Mastercard'),
                  ],
                ),
              ],

              // Subscription Management Box (If already Premium)
              if (isAlreadyPremium) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Management',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your VIP membership is currently active with full access to all AI features.',
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _handleCancelSubscription,
                          icon: Icon(Icons.cancel_outlined, color: colorScheme.error, size: 20),
                          label: Text(
                            'Cancel VIP Subscription',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Guarantee & Terms
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: colorScheme.outline),
                        const SizedBox(width: 6),
                        Text(
                          '256-Bit SSL Encrypted • SBP Compliant Payment Gateways',
                          style: TextStyle(fontSize: 11.5, color: colorScheme.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By continuing, you agree to our Terms of Service & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, color: colorScheme.outlineVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D2930).withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF7E3B50), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5A267),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelectionTile({
    required String keyId,
    required String title,
    required String price,
    required String interval,
    required String billedText,
    required String? badge,
    required bool isSelected,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = keyId),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF7E3B50).withValues(alpha: 0.07)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF7E3B50) : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF7E3B50) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7E3B50) : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        billedText,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: price,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: interval,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -9,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A267),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
