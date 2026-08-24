import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../closet/presentation/providers/closet_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../stylist/presentation/providers/stylist_provider.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../../../../core/widgets/fitlens_logo.dart';
import '../../../../core/widgets/app_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final userProfileAsync = ref.watch(userProfileProvider);
    final url = userProfileAsync.value?['profilePictureUrl'] as String? ?? user?.photoURL;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Real dynamic counts from providers
    final wardrobeItems = ref.watch(closetProvider).value ?? [];
    final wardrobeCount = wardrobeItems.length;

    final stylistSessions = ref.watch(chatSessionsProvider).value ?? [];
    final savedLooksCount = stylistSessions.length;

    final historyList = ref.watch(historyNotifierProvider).value ?? [];
    final analysesCount = historyList.length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const FitLensLogo(fontSize: 24),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.primary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: FloatingFashionBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              Column(
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                    image: AppImage.provider(url) != null
                        ? DecorationImage(
                            image: AppImage.provider(url)!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: url == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(64),
                          child: Icon(Icons.person, size: 64, color: colorScheme.onSurfaceVariant),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  ref.watch(authStateChangesProvider).value?.displayName ?? 'FitLens User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  ref.watch(authStateChangesProvider).value?.email ?? '@user',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.push('/settings');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit your profile in Settings.')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    context,
                    '$wardrobeCount',
                    'Wardrobe',
                    onTap: () => context.push('/closet'),
                  ),
                  Container(width: 1, height: 48, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _buildStat(
                    context,
                    '$savedLooksCount',
                    'Saved Looks',
                    onTap: () => context.push('/stylist'),
                  ),
                  Container(width: 1, height: 48, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _buildStat(
                    context,
                    '$analysesCount',
                    'Analyses',
                    onTap: () => context.push('/history'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildBentoCard(
                  context,
                  title: 'My Colors',
                  icon: Icons.palette,
                  onTap: () => context.push('/my-colors'),
                ),
                _buildBentoCard(
                  context,
                  title: 'My Wardrobe',
                  icon: Icons.checkroom,
                  onTap: () => context.push('/closet'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWideBentoCard(
              context,
              title: 'Analysis History',
              icon: Icons.history,
              onTap: () => context.push('/history'),
            ),
            const SizedBox(height: 16),
            _buildWideBentoCard(
              context,
              title: 'AI Body Sizing',
              icon: Icons.straighten,
              onTap: () => context.push('/sizing'),
            ),
            const SizedBox(height: 16),
            _buildWideBentoCard(
              context,
              title: 'AI Stylist',
              icon: Icons.auto_awesome,
              isPro: true,
              onTap: () => context.push('/stylist'),
            ),
            const SizedBox(height: 16),
            _buildWideBentoCard(
              context,
              title: ref.watch(subscriptionProvider).isPremium
                  ? 'FitLens VIP Active'
                  : 'Upgrade to FitLens VIP',
              subtitle: ref.watch(subscriptionProvider).isPremium
                  ? 'Unlimited AI Sizing & Stylist Access'
                  : '${ref.watch(subscriptionProvider).remainingSizingTries} of 3 free demo sizing scans left',
              icon: Icons.workspace_premium,
              isPro: true,
              onTap: () => context.push('/premium'),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                icon: Icon(Icons.logout, color: colorScheme.error),
                label: Text('Logout', style: TextStyle(color: colorScheme.error)),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }
    return content;
  }

  Widget _buildBentoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideBentoCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPro = false,
    String badgeText = 'Pro',
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: subtitle != null ? 140 : 128,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isPro ? Border.all(color: colorScheme.primary.withValues(alpha: 0.1)) : null,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPro ? colorScheme.primary : colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isPro ? colorScheme.onPrimary : colorScheme.primary),
                ),
                if (isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
