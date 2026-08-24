import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/floating_fashion_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FloatingFashionBackground(
        child: Stack(
          children: [
          // Decorative background elements
          Positioned(
            top: MediaQuery.of(context).size.height * -0.1,
            right: MediaQuery.of(context).size.width * -0.05,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * -0.1,
            left: MediaQuery.of(context).size.width * -0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Blur overlay to simulate mix-blend-multiply and blur-3xl
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                children: [
                  // Header / Skip
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        textStyle: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.14,
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                  // Main Content Area
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildPage(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAnrVsnFWp2_7GadEDnsvh1QLgdxLfnu7N0FOSlH3sC9dboMSXhC3SEgh827BN1tkHjfttF8Le8-VX5w-ezz-zQMOpzZSxZV-a_ZrJ7uisYViPTQCGjh0DsejcdKA0-Bs8SstVI97n4453HjvddBAZWxgJ2bLkmGjfUaLm4aFxb5y8YzSmGH-JxdyZ0Vn25dYMHV8hwy_nFxqesZWpk0_MojsKNlj1hwOcpRNxZ2ARTMWa9NtovxiICzg',
                          title: 'Discover Your Style',
                          subtitle: 'Let AI understand your personal style and help you create looks that feel uniquely you.',
                          showSparkle: true,
                        ),
                        _buildPage(
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDmON4zO0KNrm8ao-QsULKYUj8Xx5Y50nS4wRNjtJXUxT0AYrDmIhtLNDQty7YTunmOUgxv-gIcUpb4K2LbzFZ45Tjxz7fVTmWav9sDmKQomKXXwallTKr1KJI_T6gS0LH3AxKDnaPzyB3DEL4yRwOF-GBXS0z5uIfMyesMXgV1DrxYOQjms8TodctVuZLjlsWKeuvY9XOEiYvND_Y5otTYRfCvrh1CqXle6Y5VlpGsbGDB0Rk8QuQ2yA',
                          title: 'Shop Smarter',
                          subtitle: 'Receive AI-powered buying recommendations before purchasing.',
                          showSparkle: false,
                        ),
                      ],
                    ),
                  ),
                  // Footer Actions
                  Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(0),
                          const SizedBox(width: 12),
                          _buildDot(1),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Primary Action
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            elevation: 8,
                            shadowColor: const Color(0x143D2930),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == 0 ? 'Next' : 'Get Started',
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildPage({
    required String imageUrl,
    required String title,
    required String subtitle,
    bool showSparkle = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image Carousel Container
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 32),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x143D2930), // rgba(61,41,48,0.08)
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (showSparkle)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Text Content
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
