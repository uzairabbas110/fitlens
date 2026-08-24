import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/floating_fashion_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FloatingFashionBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Privacy Policy',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.secondary.withValues(alpha: 0.15),
                            colorScheme.primary.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.privacy_tip_rounded, color: colorScheme.secondary, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'FitLens Privacy Commitment',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last Updated: August 2026\nVersion 1.2',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your privacy and personal style data are paramount to us. This Privacy Policy explains how FitLens collects, uses, protects, and handles your information when you use our AI fashion styling application.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1
                    _buildSectionCard(
                      context,
                      icon: Icons.badge_outlined,
                      title: '1. Information We Collect',
                      content:
                          '• Account Information: Name, email address, and profile photo provided when signing in.\n'
                          '• Wardrobe & Fashion Photos: Clothing images, outfit photos, and color palette selfies you choose to upload for analysis.\n'
                          '• Location Data: Optional approximate city or GPS coordinates used exclusively to retrieve local weather conditions and suggest temperature-appropriate outfits.\n'
                          '• Sizing & Proportion Inputs: User-provided or estimated sizing measurements (e.g. chest, waist) used solely for clothing fit advice.',
                    ),
                    const SizedBox(height: 14),

                    // Section 2
                    _buildSectionCard(
                      context,
                      icon: Icons.psychology_outlined,
                      title: '2. How We Use Your Data & AI Processing',
                      content:
                          '• Delivering AI Stylist Recommendations: Processing your photos through automated visual recognition models to identify garment categories, color seasons, and outfit coordination.\n'
                          '• Wardrobe Management: Organizing and categorizing your digital closet.\n'
                          '• Personalized Experience: Tailoring fashion inspirations and seasonal recommendations.\n'
                          '• Non-Commercial AI Commitment: Your photos are used strictly to provide the styling service to you and are never sold, rented, or distributed to data brokers.',
                    ),
                    const SizedBox(height: 14),

                    // Section 3
                    _buildSectionCard(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: '3. Data Security & Storage Architecture',
                      content:
                          '• Encryption in Transit & Rest: All network communication between the app and servers is encrypted using modern TLS 1.3 / HTTPS encryption.\n'
                          '• Isolated Cloud Storage: Wardrobe and outfit imagery are stored in isolated, secure cloud object storage with strict access controls.\n'
                          '• Zero Exposed Credentials: All artificial intelligence and storage operations are handled through hardened, rate-limited server proxies.',
                    ),
                    const SizedBox(height: 14),

                    // Section 4
                    _buildSectionCard(
                      context,
                      icon: Icons.share_location_outlined,
                      title: '4. Third-Party Services & Integrations',
                      content:
                          'We integrate trusted cloud infrastructure to power the app:\n\n'
                          '• Firebase Authentication: Secure identity management.\n'
                          '• Weather Intelligence: Open-Meteo and meteorological services for climate advice.\n'
                          '• Cloudflare R2: High-speed, isolated image storage.\n'
                          '• Google Gemini AI: Multimodal fashion and style generation models.',
                    ),
                    const SizedBox(height: 14),

                    // Section 5
                    _buildSectionCard(
                      context,
                      icon: Icons.delete_sweep_outlined,
                      title: '5. Your Rights & Data Deletion (GDPR / CCPA)',
                      content:
                          'You maintain complete control over your personal information:\n\n'
                          '• Access & Export: View all your saved wardrobe items and color analysis history at any time.\n'
                          '• Wardrobe Deletion: Delete individual clothing items directly from your digital closet, which immediately removes the associated image from cloud storage.\n'
                          '• Full Account Deletion: You can request complete account deletion in the app Settings, which permanently purges your account, profile, wardrobe, and all history records.',
                    ),
                    const SizedBox(height: 14),

                    // Section 6
                    _buildSectionCard(
                      context,
                      icon: Icons.child_care_rounded,
                      title: '6. Children’s Privacy',
                      content:
                          'FitLens is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe a child has provided us with personal data, please contact support for immediate deletion.',
                    ),
                    const SizedBox(height: 14),

                    // Section 7
                    _buildSectionCard(
                      context,
                      icon: Icons.contact_support_outlined,
                      title: '7. Privacy Inquiries & Data Protection Officer',
                      content:
                          'For any questions regarding this Privacy Policy or your data rights, please contact our Privacy Team:\n\n'
                          'Email: privacy@fitlens.app\n'
                          'Support: support@fitlens.app\n'
                          'Address: FitLens Fashion AI Technologies',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
