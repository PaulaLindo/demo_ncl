// lib/widgets/validated_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

import '../utils/color_utils.dart';

import '../utils/validators.dart';

/// Enhanced TextField with validation and better UX
class ValidatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool showCounter;

  const ValidatedTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.enabled = true,
    this.showCounter = true,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;
  bool _hasInteracted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: _hasInteracted ? _errorText : null,
            counterText: widget.showCounter ? null : '',
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppTheme.containerBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.redStatus),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.redStatus, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor.withCustomOpacity(0.5)),
            ),
          ),
          validator: (value) {
            if (widget.validator != null) {
              final error = widget.validator!(value);
              if (mounted) {
                setState(() => _errorText = error);
              }
              return error;
            }
            return null;
          },
          onChanged: (value) {
            if (!_hasInteracted) {
              setState(() => _hasInteracted = true);
            }
            
            // Real-time validation
            if (widget.validator != null) {
              final error = widget.validator!(value);
              if (mounted) {
                setState(() => _errorText = error);
              }
            }
            
            widget.onChanged?.call(value);
          },
        ),
      ],
    );
  }
}

/// Phone Number TextField with formatting
class PhoneTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.validator,
    this.onChanged,
  });

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _formatPhoneNumber() {
    final text = _controller.text.replaceAll(RegExp(r'[\s\-]'), '');
    if (text.length <= 10) {
      String formatted = '';
      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) {
          formatted += ' ';
        }
        formatted += text[i];
      }
      
      if (formatted != _controller.text) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: _controller,
      label: widget.label,
      hint: '082 123 4567',
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_rounded),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: widget.validator ?? Validators.phone,
      onChanged: widget.onChanged,
      showCounter: false,
    );
  }
}

/// Address TextField with Google Places autocomplete placeholder
class AddressTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;

  const AddressTextField({
    super.key,
    this.controller,
    this.label = 'Address',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: controller,
      label: label,
      hint: 'Enter your full address',
      keyboardType: TextInputType.streetAddress,
      prefixIcon: const Icon(Icons.location_on_rounded),
      maxLines: 2,
      validator: validator ?? Validators.address,
    );
  }
}