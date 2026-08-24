import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/floating_fashion_background.dart';
import '../providers/settings_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../../../core/services/cloudflare_storage_service.dart';
import '../../../../core/widgets/app_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/error_handler.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: FloatingFashionBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () => _showEditProfileDialog(context),
              ),
              Divider(height: 1, color: colorScheme.surfaceContainerHighest),
              _buildListTile(
                context,
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              Divider(height: 1, color: colorScheme.surfaceContainerHighest),
              _buildListTile(
                context,
                icon: Icons.location_on,
                title: 'Change Location',
                onTap: () => _showLocationDialog(context, ref),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Membership & VIP'),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.workspace_premium,
                title: 'FitLens Premium',
                trailingText: ref.watch(subscriptionProvider).isPremium
                    ? 'VIP Active'
                    : '${ref.watch(subscriptionProvider).remainingSizingTries}/3 Free Scans',
                onTap: () => context.push('/premium'),
              ),
              if (ref.watch(subscriptionProvider).isPremium) ...[
                Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                _buildListTile(
                  context,
                  icon: Icons.cancel_outlined,
                  title: 'Cancel VIP Subscription',
                  onTap: () => _showCancelSubscriptionDialog(context, ref),
                ),
              ],
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeProvider.notifier).toggleTheme(val);
                },
              ),
              Divider(height: 1, color: colorScheme.surfaceContainerHighest),
              _buildSwitchTile(
                context,
                icon: Icons.notifications,
                title: 'Promotional Offers',
                value: settings.promotionalOffers,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).togglePromotionalOffers(val);
                },
              ),
              Divider(height: 1, color: colorScheme.surfaceContainerHighest),
              _buildSwitchTile(
                context,
                icon: Icons.alarm,
                title: 'Daily Reminders',
                value: settings.dailyOutfitReminders,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).toggleDailyOutfitReminders(val);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, 'App'),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.info,
                title: 'App Version',
                trailingText: 'v2.4.1',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'FitLens',
                    applicationVersion: '2.4.1',
                    applicationIcon: const Icon(Icons.checkroom, size: 48),
                    children: [const Text('Your personal AI stylist and wardrobe manager.')],
                  );
                },
              ),
              Divider(height: 1, color: colorScheme.surfaceContainerHighest),
              _buildListTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {
                  context.push(AppRoutes.terms);
                },
              ),
              Divider(height: 1, color: colorScheme.surfaceContainerHighest),
              _buildListTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  context.push(AppRoutes.privacyPolicy);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? colorScheme.surfaceContainerHighest,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Delete Account Button (10-Day Grace Period)
          InkWell(
            onTap: () => _confirmDeleteAccountDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_rounded, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      )),
    );
  }

  void _confirmDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 28),
            const SizedBox(width: 10),
            const Text('Delete Account?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account will be deactivated immediately and scheduled for permanent database erasure.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '10-Day Recovery Period: You can log back into your account within 10 days to restore your account. After 10 days, all your wardrobe items, photos, and styling history will be permanently erased.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onErrorContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(authControllerProvider.notifier).requestAccountDeletion();
              if (!context.mounted) return;
              if (success) {
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account deletion scheduled. You can log in within 10 days to restore your account, after which all data will be permanently erased.',
                    ),
                    duration: Duration(seconds: 6),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to request account deletion. Please try again.'),
                  ),
                );
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Icon(Icons.chevron_right, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final controller = TextEditingController(text: user?.displayName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isUploading = false;
          
          Future<void> pickAndUploadImage() async {
            try {
              final picker = ImagePicker();
              // Compress the image so it fits easily in a Firestore document
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 400,
                maxHeight: 400,
                imageQuality: 70,
              );
              if (image == null) return;
              
              setState(() => isUploading = true);
              
              final bytes = await image.readAsBytes();
              final filename = '${user?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
              
              // Upload to Storage
              final url = await CloudflareStorageService.uploadImage(bytes, filename);
              
              // Update Firebase Auth Profile (Only for standard short URLs; Auth rejects strings > 2048 chars)
              if (!url.startsWith('data:') && url.length < 2000) {
                try {
                  await user?.updatePhotoURL(url);
                  await user?.reload();
                } catch (e) {
                  debugPrint('Auth photoURL update skipped: $e');
                }
              }
              
              // Save the public URL to Firestore
              await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
                'profilePictureUrl': url,
                'profilePictureBase64': FieldValue.delete(), // clean up old base64
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
              
              ref.invalidate(authStateChangesProvider);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated successfully.')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ErrorHandler.getMessage(e, 'Unable to update profile picture. Please try again.'))),
                );
              }
            } finally {
              if (context.mounted) {
                setState(() => isUploading = false);
              }
            }
          }

          return AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isUploading ? null : pickAndUploadImage,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final userProfileAsync = ref.watch(userProfileProvider);
                      // Try Firestore URL first, fallback to Auth photoURL
                      final url = userProfileAsync.value?['profilePictureUrl'] as String? ?? user?.photoURL;
                      
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          image: AppImage.provider(url) != null
                              ? DecorationImage(image: AppImage.provider(url)!, fit: BoxFit.cover)
                              : null,
                        ),
                        child: isUploading
                            ? const Center(child: CircularProgressIndicator())
                            : url == null
                                ? const Icon(Icons.add_a_photo, size: 32)
                                : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tap picture to change', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  if (controller.text.trim().isNotEmpty) {
                    await user?.updateDisplayName(controller.text.trim());
                    await user?.reload();
                    ref.invalidate(authStateChangesProvider);
                    if (context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully.')));
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Would you like to receive a password reset email?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (user?.email != null) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ErrorHandler.getMessage(e, 'Unable to send password reset email. Please try again later.'))),
                    );
                  }
                }
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email associated with this account.')));
              }
            },
            child: const Text('Send Email'),
          ),
        ],
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

  void _showCancelSubscriptionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep VIP Access', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(subscriptionProvider.notifier).cancelSubscription();
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF3D2930),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Text(
                      'Your subscription has been canceled. You have returned to the free tier.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
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
  }
}
