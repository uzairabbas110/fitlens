import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/floating_fashion_background.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                      'Terms & Conditions',
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
                            colorScheme.primary.withValues(alpha: 0.15),
                            colorScheme.secondary.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.gavel_rounded, color: colorScheme.primary, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'FitLens Terms of Service',
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
                            'Please read these Terms & Conditions carefully before using the FitLens application. By creating an account or accessing our services, you agree to be bound by these terms.',
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
                      icon: Icons.account_circle_outlined,
                      title: '1. Account Registration & Security',
                      content:
                          'To access certain features of FitLens, such as personalized wardrobe syncing and AI recommendations, you must register for an account.\n\n'
                          '• You must provide accurate, current, and complete information during registration.\n'
                          '• You are responsible for safeguarding your password and maintaining the confidentiality of your credentials.\n'
                          '• You agree to immediately notify FitLens support of any unauthorized use of your account.',
                    ),
                    const SizedBox(height: 14),

                    // Section 2
                    _buildSectionCard(
                      context,
                      icon: Icons.auto_awesome_outlined,
                      title: '2. AI Styling & Advisory Disclaimer',
                      content:
                          'FitLens uses automated artificial intelligence models to deliver color analysis, garment matching, weather-appropriate style advice, and body proportion estimates.\n\n'
                          '• All recommendations and size estimations are provided solely for informational, educational, and stylistic guidance.\n'
                          '• Sizing recommendations do not guarantee exact garment fit due to brand-specific manufacturing variations.\n'
                          '• Color season and palette results are subjective stylistic evaluations based on your submitted photos.',
                    ),
                    const SizedBox(height: 14),

                    // Section 3
                    _buildSectionCard(
                      context,
                      icon: Icons.cloud_upload_outlined,
                      title: '3. User Content & Image Ownership',
                      content:
                          '• You retain full ownership and intellectual property rights to all photos, clothing items, and descriptions you upload to FitLens.\n'
                          '• By uploading content, you grant FitLens a limited, worldwide, non-exclusive license solely to process, host, and display your content to provide the app’s features to you.\n'
                          '• You represent and warrant that you own or have obtained all necessary permissions for any content you upload.',
                    ),
                    const SizedBox(height: 14),

                    // Section 4
                    _buildSectionCard(
                      context,
                      icon: Icons.block_outlined,
                      title: '4. Prohibited Conduct',
                      content:
                          'When using FitLens, you agree not to:\n\n'
                          '• Upload any unlawful, infringing, abusive, defamatory, or obscene imagery.\n'
                          '• Upload files containing malware, viruses, or executable scripts.\n'
                          '• Attempt to probe, bypass, reverse-engineer, or overload application rate limits and backend infrastructure.\n'
                          '• Impersonate any person or entity or misrepresent your affiliation.',
                    ),
                    const SizedBox(height: 14),

                    // Section 5
                    _buildSectionCard(
                      context,
                      icon: Icons.workspace_premium_outlined,
                      title: '5. Subscriptions & Billing',
                      content:
                          '• FitLens offers optional Premium subscription tiers unlocking enhanced features such as unlimited wardrobe items and event stylist consultations.\n'
                          '• Subscriptions are processed securely through the official App Store and Google Play Store billing channels.\n'
                          '• Subscriptions automatically renew unless cancelled at least 24 hours prior to the end of the current billing cycle.',
                    ),
                    const SizedBox(height: 14),

                    // Section 6
                    _buildSectionCard(
                      context,
                      icon: Icons.shield_outlined,
                      title: '6. Limitation of Liability',
                      content:
                          'To the maximum extent permitted by applicable law, FitLens and its operators shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your access to or inability to use the service.',
                    ),
                    const SizedBox(height: 14),

                    // Section 7
                    _buildSectionCard(
                      context,
                      icon: Icons.mail_outline_rounded,
                      title: '7. Contact & Inquiries',
                      content:
                          'If you have any questions, concerns, or legal inquiries regarding these Terms, please contact us at:\n\n'
                          'Email: support@fitlens.app\n'
                          'Website: https://fitlens.app',
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
              Icon(icon, size: 20, color: colorScheme.primary),
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
