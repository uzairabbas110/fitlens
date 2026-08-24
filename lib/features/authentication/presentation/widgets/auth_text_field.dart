import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? icon;
  final bool showEmailValidation;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.showEmailValidation = false,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = false;
  bool _isEmailValid = false;

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    if (widget.showEmailValidation) {
      _checkEmail(widget.controller.text);
      widget.controller.addListener(_onTextControllerChanged);
    }
  }

  void _onTextControllerChanged() {
    _checkEmail(widget.controller.text);
  }

  void _checkEmail(String value) {
    final valid = _emailRegExp.hasMatch(value.trim());
    if (valid != _isEmailValid) {
      setState(() {
        _isEmailValid = valid;
      });
    }
  }

  @override
  void dispose() {
    if (widget.showEmailValidation) {
      widget.controller.removeListener(_onTextControllerChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? computedSuffixIcon;

    if (widget.suffixIcon != null) {
      computedSuffixIcon = widget.suffixIcon;
    } else if (widget.obscureText) {
      computedSuffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.outline,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.showEmailValidation) {
      computedSuffixIcon = AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: _isEmailValid
            ? const Padding(
                padding: EdgeInsets.only(right: 14.0),
                child: Icon(
                  Icons.check_circle_rounded,
                  key: ValueKey('valid_email'),
                  color: Color(0xFF2E7D32), // Green Tick
                  size: 22,
                ),
              )
            : const SizedBox.shrink(key: ValueKey('empty_email')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
          child: Text(
            widget.labelText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondaryContainer,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
            prefixIcon: widget.icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Icon(
                      widget.icon,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  )
                : null,
            suffixIcon: computedSuffixIcon,
          ),
        ),
      ],
    );
  }
}