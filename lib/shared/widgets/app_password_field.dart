import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AppPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onEditingComplete,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _hide,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      onEditingComplete: widget.onEditingComplete,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _hide ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _hide = !_hide),
          icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        ),
      ),
    );
  }
}
