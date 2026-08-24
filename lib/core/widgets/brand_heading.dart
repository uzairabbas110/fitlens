import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable brand heading widget that renders in the signature
/// stylized Instagram Sans / luxury modern headline typography.
class BrandHeading extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final double letterSpacing;
  final TextOverflow? overflow;
  final int? maxLines;

  const BrandHeading(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
    this.color,
    this.textAlign = TextAlign.center,
    this.letterSpacing = -0.5,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: GoogleFonts.montserratAlternates(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
