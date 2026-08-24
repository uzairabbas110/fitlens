import 'package:flutter/material.dart';

/// Interactive real-time checklist displaying security rules for passwords
class PasswordChecklist extends StatelessWidget {
  final String password;

  const PasswordChecklist({
    super.key,
    required this.password,
  });

  bool get hasMinLength => password.length > 8; // Longer than 8 characters (at least 9)
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(password);
  bool get hasDigit => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+]').hasMatch(password);

  int get metCount {
    int count = 0;
    if (hasMinLength) count++;
    if (hasUppercase) count++;
    if (hasLowercase) count++;
    if (hasDigit) count++;
    if (hasSpecialChar) count++;
    return count;
  }

  double get strengthPercent => metCount / 5.0;

  Color _getStrengthColor(BuildContext context) {
    if (metCount <= 2) return Colors.redAccent;
    if (metCount <= 4) return Colors.amber.shade700;
    return const Color(0xFF2E7D32); // Green
  }

  String _getStrengthLabel() {
    if (password.isEmpty) return 'Enter a password';
    if (metCount <= 2) return 'Weak';
    if (metCount <= 4) return 'Moderate';
    return 'Strong & Secure';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strengthColor = _getStrengthColor(context);

    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength Header & Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Requirements',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: theme.textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: password.isEmpty ? colorScheme.outline : strengthColor,
                ),
                child: Text(_getStrengthLabel()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: strengthPercent),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Requirement Items
          _buildCheckItem(
            context,
            isMet: hasMinLength,
            label: 'Longer than 8 characters (at least 9)',
          ),
          const SizedBox(height: 6),
          _buildCheckItem(
            context,
            isMet: hasUppercase,
            label: 'At least one uppercase letter (A-Z)',
          ),
          const SizedBox(height: 6),
          _buildCheckItem(
            context,
            isMet: hasLowercase,
            label: 'At least one lowercase letter (a-z)',
          ),
          const SizedBox(height: 6),
          _buildCheckItem(
            context,
            isMet: hasDigit,
            label: 'At least one number (0-9)',
          ),
          const SizedBox(height: 6),
          _buildCheckItem(
            context,
            isMet: hasSpecialChar,
            label: 'At least one special character (!@#\$%^&*)',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context, {
    required bool isMet,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const greenColor = Color(0xFF2E7D32);

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            key: ValueKey<bool>(isMet),
            size: 16,
            color: isMet ? greenColor : colorScheme.outlineVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMet ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
