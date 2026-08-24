import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The official FitLens Two-Tone Text Logo widget (Design Option B).
/// Features "FIT" in luxury wine-burgundy / rose and "LENS" in champagne gold
/// rendered in the signature aerodynamic NEVERA typography.
class FitLensLogo extends StatelessWidget {
  final double fontSize;
  final bool showAsImage;
  final double? imageHeight;
  final MainAxisSize mainAxisSize;
  final Color? fitColor;
  final Color? lensColor;

  const FitLensLogo({
    super.key,
    this.fontSize = 28,
    this.showAsImage = false,
    this.imageHeight,
    this.mainAxisSize = MainAxisSize.min,
    this.fitColor,
    this.lensColor,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsImage) {
      return Image.asset(
        'assets/images/fitlens_logo.jpg',
        height: imageHeight ?? (fontSize * 1.8),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildTextLogo(context),
      );
    }

    return _buildTextLogo(context);
  }

  Widget _buildTextLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryFit = fitColor ?? (isDark ? const Color(0xFFFFB1C9) : const Color(0xFF7E3B50));
    final goldLens = lensColor ?? const Color(0xFFC5A267);

    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'FIT',
          style: GoogleFonts.montserratAlternates(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: primaryFit,
            letterSpacing: -0.6,
          ),
        ),
        Text(
          'LENS',
          style: GoogleFonts.montserratAlternates(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: goldLens,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}
