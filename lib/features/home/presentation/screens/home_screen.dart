import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../../core/widgets/fitlens_logo.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final user = ref.watch(authStateChangesProvider).value;
    final userProfileAsync = ref.watch(userProfileProvider);
    final url = userProfileAsync.value?['profilePictureUrl'] as String? ?? user?.photoURL;
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isPremium = ref.watch(subscriptionProvider).isPremium;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FloatingFashionBackground(
        child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(weatherProvider.notifier).refreshLocation();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100), // padding for bottom nav
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const FitLensLogo(fontSize: 28),
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
                      tooltip: 'Settings',
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),

              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Welcome back, ${user?.displayName?.split(' ').first ?? 'User'}',
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isPremium) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.push('/premium'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF7E3B50), Color(0xFFC5A267)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFC5A267).withValues(alpha: 0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.workspace_premium, color: Colors.white, size: 12),
                                        SizedBox(width: 3),
                                        Text(
                                          'VIP',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPremium
                                ? '✨ FitLens VIP • Unlimited AI Stylist Active'
                                : 'Ready to find your perfect look?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isPremium ? const Color(0xFF7E3B50) : colorScheme.onSurfaceVariant,
                              fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPremium ? const Color(0xFFC5A267) : colorScheme.surfaceContainerHighest,
                            width: isPremium ? 2.5 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPremium
                                  ? const Color(0xFFC5A267).withValues(alpha: 0.3)
                                  : const Color(0xFF3D2930).withValues(alpha: 0.08),
                              blurRadius: isPremium ? 12 : 30,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: AppImage.provider(url) != null
                              ? DecorationImage(
                                  image: AppImage.provider(url)!,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: url == null
                            ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Weather Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: weatherAsync.when(
                  data: (weather) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D2930).withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  weather.condition.toLowerCase().contains('cloud') ? Icons.cloud : Icons.wb_sunny,
                                  size: 48,
                                  color: colorScheme.tertiary,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${weather.temperature.toStringAsFixed(0)}°',
                                  style: textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.02,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _showLocationDialog(context, ref);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      weather.city,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit, size: 12, color: colorScheme.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          weather.suggestion,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // AI Style Check Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => context.push('/upload/quality'),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: colorScheme.primaryContainer, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Analyze Outfit',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get instant feedback on your look.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color ?? colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3D2930).withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_forward, color: colorScheme.primaryContainer, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Bento Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildQuickAction(
                      context: context,
                      title: 'Analyze Outfit',
                      icon: Icons.camera_alt,
                      onTap: () => context.push('/upload/quality'),
                    ),
                    _buildQuickAction(
                      context: context,
                      title: 'My Colors',
                      icon: Icons.palette,
                      onTap: () => context.push('/color-analysis'),
                    ),
                    _buildQuickAction(
                      context: context,
                      title: 'AI Stylist',
                      icon: Icons.psychology,
                      onTap: () => context.push(AppRoutes.stylist),
                    ),
                    _buildQuickAction(
                      context: context,
                      title: 'My Wardrobe',
                      icon: Icons.checkroom,
                      onTap: () => context.go('/closet'), // Update route if needed
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // FitLens VIP Studio Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'VIP Fashion Studio',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/premium'),
                          child: Text(
                            isPremium ? 'VIP Active' : 'Explore VIP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7E3B50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 10x30 Capsule Card
                    _buildVipFeatureBanner(
                      context: context,
                      title: '10x30 Capsule Wardrobe',
                      subtitle: 'Generate 30 outfits from 10 core interchangeable closet pieces.',
                      badge: '10x30 FORMULA',
                      icon: Icons.auto_awesome_mosaic,
                      gradient: const [Color(0xFF3D2930), Color(0xFF7E3B50)],
                      onTap: () => context.push(AppRoutes.capsule),
                    ),
                    const SizedBox(height: 10),

                    // Travel Packing Card
                    _buildVipFeatureBanner(
                      context: context,
                      title: 'AI Travel Packing Assistant',
                      subtitle: 'Destination weather & activity matcher with day-by-day outfits.',
                      badge: 'SMART LUGGAGE',
                      icon: Icons.flight_takeoff,
                      gradient: const [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                      onTap: () => context.push(AppRoutes.travelPacking),
                    ),
                    const SizedBox(height: 10),

                    // Event Stylist Card
                    _buildVipFeatureBanner(
                      context: context,
                      title: 'Event & Occasion Stylist',
                      subtitle: 'Red-carpet & tailored looks for weddings, interviews & dates.',
                      badge: 'HAUTE COUTURE',
                      icon: Icons.celebration,
                      gradient: const [Color(0xFF4A154B), Color(0xFF9E1030)],
                      onTap: () => context.push(AppRoutes.eventStylist),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    )),
  );
}

  Widget _buildQuickAction({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D2930).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipFeatureBanner({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFFC5A267), size: 24),
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
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'City Name',
              ),
            ),
            const SizedBox(height: 16),
            const Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.pop();
                ref.read(weatherProvider.notifier).refreshLocation();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fetching precise GPS location...')));
              },
              icon: const Icon(Icons.my_location),
              label: const Text('Get Precise Location'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(weatherProvider.notifier).setCity(controller.text.trim());
                context.pop();
              }
            },
            child: const Text('Search City'),
          ),
        ],
      ),
    );
  }
}