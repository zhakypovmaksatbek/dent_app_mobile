import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry contentPadding;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.autofocus = false,
    this.decoration,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _displayController;
  String _rawValue = '';
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _rawValue = _cleanNumber(widget.controller.text);
    _displayController = TextEditingController();
    _updateDisplayValue();

    // Listen to external changes to the main controller
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _displayController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!_isFormatting) {
      _rawValue = _cleanNumber(widget.controller.text);
      _updateDisplayValue();
    }
  }

  String _cleanNumber(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  void _updateDisplayValue() {
    final formattedValue =
        _rawValue.isEmpty ? '' : FormatUtils.formatPhoneNumber(_rawValue);

    // Only update if different to avoid recursive updates
    if (_displayController.text != formattedValue) {
      _displayController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  void _handleTextChanged(String displayText) {
    // Extract only digits from input
    final newRawValue = _cleanNumber(displayText);

    if (newRawValue != _rawValue) {
      _isFormatting = true;
      _rawValue = newRawValue;

      // Update the actual controller with raw value
      widget.controller.text = _rawValue;

      // Call the onChanged callback with the raw value
      if (widget.onChanged != null) {
        widget.onChanged!(_rawValue);
      }

      _updateDisplayValue();
      _isFormatting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _displayController,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onChanged: _handleTextChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20), // Prevent too long inputs
      ],
      decoration:
          widget.decoration ??
          InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            errorText: widget.errorText,
            contentPadding: widget.contentPadding,
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
    );
  }
}
