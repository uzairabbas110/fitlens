import 'package:flutter/material.dart';

/// Authentic Easypaisa vector brand logo icon
class EasypaisaLogo extends StatelessWidget {
  final double size;

  const EasypaisaLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF00A859), // Official Easypaisa Green
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A859).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'e',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.72,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Authentic JazzCash vector brand logo icon
class JazzCashLogo extends StatelessWidget {
  final double size;

  const JazzCashLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE51937), // Jazz Red
            Color(0xFFFF8C00), // Jazz Orange/Gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE51937).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'J',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.65,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Authentic Visa & Mastercard dual emblem
class CardsLogo extends StatelessWidget {
  final double size;

  const CardsLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.5,
      height: size,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Mastercard Red Circle
          Positioned(
            left: 0,
            child: Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Mastercard Yellow Circle
          Positioned(
            left: size * 0.45,
            child: Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full Easypaisa Brand Pill Chip
class EasypaisaChip extends StatelessWidget {
  const EasypaisaChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00A859).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF00A859).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasypaisaLogo(size: 15),
          SizedBox(width: 6),
          Text(
            'easypaisa',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00A859),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full JazzCash Brand Pill Chip
class JazzCashChip extends StatelessWidget {
  const JazzCashChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE51937).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE51937).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          JazzCashLogo(size: 15),
          SizedBox(width: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Jazz',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE51937),
                  ),
                ),
                TextSpan(
                  text: 'Cash',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 11, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }
}

/// Full Visa / Mastercard Brand Pill Chip
class VisaMastercardChip extends StatelessWidget {
  const VisaMastercardChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F71).withValues(alpha: isDark ? 0.18 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF1A1F71).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardsLogo(size: 14),
          SizedBox(width: 6),
          Text(
            'Visa / Mastercard',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F71),
            ),
          ),
        ],
      ),
    );
  }
}
