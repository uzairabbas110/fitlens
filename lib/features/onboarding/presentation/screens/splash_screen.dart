import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/fitlens_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _sparkleController;

  final Random _random = Random();
  late List<_SparkleData> _sparkles;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Overall fade in sequence
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Background floating sparkles
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _sparkles = List.generate(15, (index) => _SparkleData(
      left: _random.nextDouble(),
      top: _random.nextDouble(),
      size: _random.nextDouble() * 8 + 8, // 8 to 16
      delay: _random.nextDouble(),
      speed: _random.nextDouble() * 0.5 + 0.5,
    ));

    _startTimer();
  }

  Future<void> _startTimer() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    if (!mounted) return;
    if (hasSeenOnboarding) {
       context.go('/login');
    } else {
       context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Sparkles Background Layer
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return Stack(
                children: _sparkles.map((sparkle) {
                  // Calculate continuous floating
                  double progress = (_sparkleController.value * sparkle.speed + sparkle.delay) % 1.0;
                  
                  // y moves up, opacity fades in then out
                  double yOffset = -50 * progress;
                  double opacity = progress < 0.2 ? progress / 0.2 : 
                                   progress > 0.8 ? (1.0 - progress) / 0.2 : 1.0;

                  return Positioned(
                    left: MediaQuery.of(context).size.width * sparkle.left,
                    top: MediaQuery.of(context).size.height * sparkle.top + yOffset,
                    child: Opacity(
                      opacity: opacity * 0.6,
                      child: Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFFD08A9E), // Accent color from prototype
                        size: sparkle.size,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          // Subtle Ambient Gradient Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Canvas
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with Pulse
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(parent: _fadeController, curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
                      CurvedAnimation(parent: _fadeController, curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.03),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3D2930).withValues(alpha: 0.08 + (_pulseController.value * 0.04)),
                                  blurRadius: 30 + (_pulseController.value * 10),
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const FitLensLogo(fontSize: 40),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Subtitle Typography
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
                      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
                    ),
                    child: Text(
                      'DRESS SMARTER',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 13,
                            letterSpacing: 5,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 64),
                
                // Loading Indicator
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(parent: _fadeController, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
                      CurvedAnimation(parent: _fadeController, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primaryContainer,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Curating your style...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleData {
  final double left;
  final double top;
  final double size;
  final double delay;
  final double speed;

  _SparkleData({
    required this.left,
    required this.top,
    required this.size,
    required this.delay,
    required this.speed,
  });
}
