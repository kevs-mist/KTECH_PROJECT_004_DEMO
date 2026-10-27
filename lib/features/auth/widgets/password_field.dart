import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../validators.dart';
import 'auth_text_field.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isCreate;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PasswordField({
    super.key,
    this.label = 'Password',
    this.hint,
    this.initialValue,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.isCreate = false,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: widget.label,
      hint: widget.hint,
      initialValue: widget.initialValue,
      obscureText: _obscureText,
      enabled: widget.enabled,
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator ??
          (value) => Validators.validatePassword(value, isCreate: widget.isCreate)?.message,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppTheme.textSecondary,
        ),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
        style: IconButton.styleFrom(
          minimumSize: const Size(AppTheme.tapTarget, AppTheme.tapTarget),
        ),
      ),
    );
  }
}
