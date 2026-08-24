import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated background widget displaying gently floating and rotating
/// fashion icons (hangers, clothing, accessories, stitches, and sparkles)
/// with subtle parallax depth and ambient lighting.
class FloatingFashionBackground extends StatefulWidget {
  final Widget child;
  final bool showGradients;
  final double iconOpacity;

  const FloatingFashionBackground({
    super.key,
    required this.child,
    this.showGradients = true,
    this.iconOpacity = 0.16,
  });

  @override
  State<FloatingFashionBackground> createState() =>
      _FloatingFashionBackgroundState();
}

class _FloatingFashionBackgroundState extends State<FloatingFashionBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Rich list of fashion particle parameters distributed across the entire screen
  final List<_FashionParticle> _particles = const [
    // Top Left - Coat Hanger
    _FashionParticle(
      icon: Icons.checkroom_rounded,
      relativeX: 0.10,
      relativeY: 0.06,
      size: 46,
      speedMultiplier: 1.0,
      phaseShift: 0.0,
      rotationAmplitude: 0.25,
      bobbingDistance: 18.0,
    ),
    // Top Center - Sparkles
    _FashionParticle(
      icon: Icons.auto_awesome,
      relativeX: 0.50,
      relativeY: 0.04,
      size: 28,
      speedMultiplier: 1.3,
      phaseShift: 1.5,
      rotationAmplitude: 0.35,
      bobbingDistance: 14.0,
    ),
    // Top Right - Dress / Style
    _FashionParticle(
      icon: Icons.style_outlined,
      relativeX: 0.88,
      relativeY: 0.09,
      size: 42,
      speedMultiplier: 0.8,
      phaseShift: 1.2,
      rotationAmplitude: -0.22,
      bobbingDistance: 20.0,
    ),
    // Upper Left - Measuring Tape / Sizing
    _FashionParticle(
      icon: Icons.straighten,
      relativeX: 0.28,
      relativeY: 0.18,
      size: 32,
      speedMultiplier: 1.1,
      phaseShift: 3.4,
      rotationAmplitude: 0.30,
      bobbingDistance: 16.0,
    ),
    // Upper Right - Diamond / Luxury
    _FashionParticle(
      icon: Icons.diamond_outlined,
      relativeX: 0.72,
      relativeY: 0.20,
      size: 30,
      speedMultiplier: 1.2,
      phaseShift: 4.8,
      rotationAmplitude: -0.28,
      bobbingDistance: 15.0,
    ),
    // Mid Left - Dry Cleaning / Clothing
    _FashionParticle(
      icon: Icons.dry_cleaning_outlined,
      relativeX: 0.07,
      relativeY: 0.36,
      size: 48,
      speedMultiplier: 0.9,
      phaseShift: 2.8,
      rotationAmplitude: -0.18,
      bobbingDistance: 22.0,
    ),
    // Mid Center - Coat Hanger 2
    _FashionParticle(
      icon: Icons.checkroom_outlined,
      relativeX: 0.52,
      relativeY: 0.40,
      size: 44,
      speedMultiplier: 1.05,
      phaseShift: 0.5,
      rotationAmplitude: 0.20,
      bobbingDistance: 18.0,
    ),
    // Mid Right - Shopping Bag
    _FashionParticle(
      icon: Icons.shopping_bag_outlined,
      relativeX: 0.92,
      relativeY: 0.42,
      size: 42,
      speedMultiplier: 1.15,
      phaseShift: 0.8,
      rotationAmplitude: 0.18,
      bobbingDistance: 20.0,
    ),
    // Lower Left Center - Palette / Colors
    _FashionParticle(
      icon: Icons.palette_outlined,
      relativeX: 0.30,
      relativeY: 0.56,
      size: 34,
      speedMultiplier: 0.95,
      phaseShift: 4.1,
      rotationAmplitude: -0.25,
      bobbingDistance: 17.0,
    ),
    // Lower Left - Large Coat Hanger
    _FashionParticle(
      icon: Icons.checkroom_rounded,
      relativeX: 0.12,
      relativeY: 0.70,
      size: 50,
      speedMultiplier: 0.85,
      phaseShift: 1.9,
      rotationAmplitude: 0.24,
      bobbingDistance: 24.0,
    ),
    // Lower Center - Sparkles
    _FashionParticle(
      icon: Icons.auto_awesome,
      relativeX: 0.55,
      relativeY: 0.68,
      size: 32,
      speedMultiplier: 1.4,
      phaseShift: 2.2,
      rotationAmplitude: 0.32,
      bobbingDistance: 16.0,
    ),
    // Lower Right - Tailoring Scissors
    _FashionParticle(
      icon: Icons.content_cut_outlined,
      relativeX: 0.86,
      relativeY: 0.74,
      size: 38,
      speedMultiplier: 1.1,
      phaseShift: 5.2,
      rotationAmplitude: -0.30,
      bobbingDistance: 19.0,
    ),
    // Bottom Left - Watch / Accessories
    _FashionParticle(
      icon: Icons.watch_outlined,
      relativeX: 0.22,
      relativeY: 0.88,
      size: 34,
      speedMultiplier: 0.9,
      phaseShift: 3.7,
      rotationAmplitude: 0.18,
      bobbingDistance: 18.0,
    ),
    // Bottom Center - Coat Hanger 3
    _FashionParticle(
      icon: Icons.checkroom_outlined,
      relativeX: 0.52,
      relativeY: 0.90,
      size: 46,
      speedMultiplier: 1.0,
      phaseShift: 1.1,
      rotationAmplitude: -0.22,
      bobbingDistance: 22.0,
    ),
    // Bottom Right - Shirt / Garment
    _FashionParticle(
      icon: Icons.dry_cleaning_rounded,
      relativeX: 0.84,
      relativeY: 0.92,
      size: 40,
      speedMultiplier: 0.95,
      phaseShift: 2.6,
      rotationAmplitude: 0.16,
      bobbingDistance: 20.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient background gradient
          if (widget.showGradients)
            Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.5),
                  radius: 1.5,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.28),
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),

        // Floating Fashion Particles Layer
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value * 2 * math.pi;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;

                    return Stack(
                      children: _particles.map((particle) {
                        final localT = progress * particle.speedMultiplier +
                            particle.phaseShift;

                        final offsetY =
                            math.sin(localT) * particle.bobbingDistance;
                        final offsetX =
                            math.cos(localT * 0.7) * (particle.bobbingDistance * 0.5);
                        final angle =
                            math.sin(localT * 0.8) * particle.rotationAmplitude;

                        final posX = (particle.relativeX * width) + offsetX;
                        final posY = (particle.relativeY * height) + offsetY;

                        final opacity = (widget.iconOpacity +
                                (math.sin(localT) * 0.04))
                            .clamp(0.06, 0.35);

                        return Positioned(
                          left: posX - (particle.size / 2),
                          top: posY - (particle.size / 2),
                          child: Transform.rotate(
                            angle: angle,
                            child: Opacity(
                              opacity: opacity,
                              child: Icon(
                                particle.icon,
                                size: particle.size,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Main content foreground
        widget.child,
      ],
    ),
  );
}
}

class _FashionParticle {
  final IconData icon;
  final double relativeX;
  final double relativeY;
  final double size;
  final double speedMultiplier;
  final double phaseShift;
  final double rotationAmplitude;
  final double bobbingDistance;

  const _FashionParticle({
    required this.icon,
    required this.relativeX,
    required this.relativeY,
    required this.size,
    required this.speedMultiplier,
    required this.phaseShift,
    required this.rotationAmplitude,
    required this.bobbingDistance,
  });
}
